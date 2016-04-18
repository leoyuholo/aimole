
_ = require 'lodash'
async = require 'async'
Elo = require 'arpad'

module.exports = ($) ->
	self = {}

	aroundMe = (profile, done) ->
		$.stores.profileStore.listByGameId profile.gameId, (err, profiles) ->
			return $.utils.onError done, err if err

			console.log profiles

			sortedScores = _.map(profiles, 'score').sort().reverse()
			rank = _.lastIndexOf sortedScores, profile.score

			return $.utils.onError done, new Error('Congraduations, you\'re No.1 in this game! Please sit tight and wait for challengers.') if rank == 0

			sortedProfiles = _.orderBy(profiles, 'score', 'desc')
			result = _.slice sortedProfiles, _.max([0, rank - 5]), rank + 1

			console.log 'aroundMe', sortedScores, rank, sortedProfiles, result

			done null, result

	pickOpponents = (profiles, count, done) ->
		done null, _.sampleSize profiles, count
		# async.filter _.shuffle(profiles), ( (profile, done) ->
		# 	return done null, true if profile.ai
		# 	$.services.profileService.findRecentMatch profile.gameId, profile.userId, (err, match) ->
		# 		return $.utils.onError done, err if err
		# 		done null, match.state == 'evaluated'
		# ), (err, profiles) ->
		# 	return $.utils.onError done, err if err
		# 	return done new Error() if !profiles || profiles.length < count
		# 	done null, _.sampleSize profiles, count

	self.matchUp = (submission, done) ->
		me =
			type: 'submission'
			name: submission.displayName
			userId: submission.userId
			submissionId: submission.objectId

		$.stores.gameStore.findById submission.gameId, (err, game) ->
			return $.utils.onError done, err if err

			profile =
				gameId: submission.gameId
				userId: submission.userId
				displayName: submission.displayName
				ai: false
				score: game.ranking.baseScore

			$.services.profileService.addIfNotExist profile, (err, profile) ->
				return $.utils.onError done, err if err
				return done null, [me] if game.players < 2

				aroundMe profile, (err, profiles) ->
					return $.utils.onError done, err if err

					pickOpponents _.reject(profiles, ['userId', me.userId]), game.players - 1, (err, opponents) ->
						return $.utils.onError done, err if err

						opponents = _.map opponents, (o) ->
							return {
								type: if o.ai then 'ai' else 'submission'
								name: o.displayName
								userId: o.userId
								submissionId: if o.ai then null else o.lastSubmissionId
							}

						done null, _.shuffle opponents.concat me

	computeEloChange = (game, players, winner, done) ->
		async.parallel [
			_.partial $.stores.profileStore.findByGameIdAndUserId, game.objectId, players[0].userId
			_.partial $.stores.profileStore.findByGameIdAndUserId, game.objectId, players[1].userId
		], (err, profiles) ->
			return $.utils.onError done, err if err

			elo = new Elo()
			scores = [0, 0]
			switch winner
				when -1
					scores[0] = elo.newRatingIfTied profiles[0].score, profiles[1].score
					scores[1] = elo.newRatingIfTied profiles[1].score, profiles[0].score
				when 0
					scores[0] = elo.newRatingIfWon profiles[0].score, profiles[1].score
					scores[1] = elo.newRatingIfLost profiles[1].score, profiles[0].score
				when 1
					scores[0] = elo.newRatingIfLost profiles[0].score, profiles[1].score
					scores[1] = elo.newRatingIfWon profiles[1].score, profiles[0].score
				else
					return done null, [0, 0]
			scores = _.map scores, (s) -> _.max [game.ranking.baseScore, s]
			done null, [scores[0] - profiles[0].score, scores[1] - profiles[1].score]

	self.updateScore = (matchWithCode, result, done) ->
		return done null if !matchWithCode.submitBy.ranked

		game = matchWithCode.game
		players = matchWithCode.players
		lastAction = _.last(result).action

		switch game.ranking.scheme
			when 'max'
				submission =
					submissionId: players[0].submissionId
					matchId: matchWithCode.objectId
					updatedAt: (new Date()).toJSON()
				$.stores.profileStore.updateScoreIfHigher game.objectId, players[0].userId, lastAction.score, submission, done
			when 'elo'
				computeEloChange game, players, lastAction.winner, (err, scoreIncrement) ->
					return $.utils.onError done, err if err
					async.parallel [
						_.partial $.stores.profileStore.incrementScore, game.objectId, players[0].userId, scoreIncrement[0]
						_.partial $.stores.profileStore.incrementScore, game.objectId, players[1].userId, scoreIncrement[1]
					], done
			when 'podium'
				# TODO: avoid new score lower than baseScore
				podium = _.last(result).action.podium
				updateScoreFuncs = _.map matchWithCode.players, (player, index) ->
					_.partial $.stores.profileStore.incrementScore, game.objectId, player.userId, podium[index]
				async.parallel updateScoreFuncs, done
			else
				return done new Error("Unknow ranking scheme: #{game.ranking.scheme}")

	self.updateLeaderBoard = (gameId, done) ->
		# $.stores.profileStore.listByGameIdSortByScoreWithLimit gameId, $.constants.leaderBoard.size, (err, profiles) ->
		$.stores.profileStore.listByGameId gameId, (err, profiles) ->
			return $.utils.onError done, err if err
			leaderBoard = _.orderBy _.map(profiles, $.models.Profile.envelop), 'score', 'desc'
			leaderBoard = _.take leaderBoard, $.constants.leaderBoard.size
			$.stores.cacheStore.upsert "leaderboard-#{gameId}", leaderBoard, done

	return self
