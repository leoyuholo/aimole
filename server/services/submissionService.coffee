
_ = require 'lodash'
async = require 'async'

module.exports = ($) ->
	self = {}

	submit = (newSubmission, done) ->
		$.services.codeService.sendToAnalyse newSubmission.gameId, newSubmission.language, newSubmission.code, (err, result) ->
			return $.utils.onError done, err if err
			return done new Error("Compile Error: #{result.compileErrorMessage}") if !result.ok && result.compileErrorMessage
			return done new Error("Error: #{result.errorMessage}") if !result.ok
			$.stores.submissionStore.create newSubmission, done

	submitMatch = (submission, players, ranked, done) ->
		me =
			type: 'submission'
			name: submission.displayName
			userId: submission.userId
			submissionId: submission.objectId

		matchInfo =
			submitBy:
				userId: submission.userId
				displayName: submission.displayName
				ranked: ranked
			gameId: submission.gameId
			players: _.map players, (p) -> if p.type == 'me' then me else p

		$.services.matchService.viewMatch matchInfo, (err, match) ->
			return $.utils.onError done, err if err
			$.stores.submissionStore.addMatchId submission.objectId, match.objectId, (err) ->
				return $.utils.onError done, err if err
				done null, match

	self.try = (newSubmission, players, done) ->
		submit newSubmission, (err, submission) ->
			return $.utils.onError done, err if err
			submitMatch submission, players, false, done

	self.rank = (newSubmission, done) ->
		submit newSubmission, (err, submission) ->
			return $.utils.onError done, err if err
			$.services.rankingService.matchUp submission, (err, players) ->
				return $.utils.onError done, err if err
				submitMatch submission, players, true, (err, match) ->
					return $.utils.onError done, err if err

					profileSubmission =
						submissionId: submission.objectId
						matchId: match.objectId
						players: players
						updatedAt: (new Date()).toJSON()

					$.stores.profileStore.setLastSubmissionId submission.gameId, submission.userId, submission.objectId, (err) ->
						return $.utils.onError done, err if err
						async.each players, ( (player, done) ->
							$.stores.profileStore.addSubmission submission.gameId, player.userId, profileSubmission, done
						), (err) ->
							return $.utils.onError done, err if err
							done null, match

	return self
