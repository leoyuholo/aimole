
_ = require 'lodash'
async = require 'async'
Elo = require 'arpad'

module.exports = ($) ->
	self = {}

	aroundMe = (profile, done) ->
		# TODO: use leaderboard cache
		$.stores.profileStore.listByGameId profile.gameId, (err, profiles) ->
			return $.utils.onError done, err if err

			rank = _.lastIndexOf _.orderBy(_.map(profiles, 'score'), '', 'desc'), profile.score

			return $.utils.onError done, new Error("Congraduations, you're No.1 in this game! Please sit tight and wait for challengers.") if rank == 0

			done null, _.slice _.orderBy(profiles, 'score', 'desc'), _.max([0, rank - 5]), rank + 1

	pick = (profiles, count, done) ->
		# TODO: ensure opponent is not running a match, related to submit.coffee
		done null, _.sampleSize profiles, count

	self.matchUp = (submission, user, done) ->
		me =
			type: 'submission'
			name: user.displayName
			userId: user.id
			submissionId: submission.objectId

		$.stores.gameStore.findById submission.gameId, (err, game) ->
			return $.utils.onError done, err if err

			return done null, [me] if game.players < 2

			profile =
				gameId: submission.gameId
				userId: submission.userId
				displayName: submission.displayName
				pictureUrl: user.profilePictureUrl
				ai: false
				score: game.ranking.baseScore

			$.stores.profileStore.addIfNotExist profile, (err, profile) ->
				return $.utils.onError done, err if err

				aroundMe profile, (err, profiles) ->
					return $.utils.onError done, err if err

					pick _.reject(profiles, ['userId', me.userId]), game.players - 1, (err, opponents) ->
						return $.utils.onError done, err if err

						opponents = _.map opponents, (o) ->
							return {
								type: if o.ai then 'ai' else 'submission'
								name: o.displayName
								userId: o.userId
								submissionId: if o.ai then null else _.last(o.submissions)?.submissionId
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
				$.stores.profileStore.updateScoreIfHigher game.objectId, players[0].userId, lastAction.score, done
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
		$.stores.profileStore.listByGameId gameId, (err, profiles) ->
			return $.utils.onError done, err if err
			leaderBoard = _.orderBy _.map(profiles, $.models.Profile.envelop), 'score', 'desc'
			$.stores.cacheStore.upsert "leaderboard-#{gameId}", leaderBoard, done

	return self
