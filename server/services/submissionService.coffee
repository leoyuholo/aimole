
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.submit = (gameId, userId, displayName, language, code, players, done) ->
		$.services.codeService.sendToAnalyse gameId, language, code, (err, result) ->
			return $.utils.onError done, err if err
			return done new Error("Compile Error: #{result.compileErrorMessage}") if !result.ok && result.compileErrorMessage
			return done new Error("Error: #{result.errorMessage}") if !result.ok

			newSubmission =
				userId: userId
				displayName: displayName
				gameId: gameId
				language: language
				code: code

			newMatch =
				submitBy: {userId: userId, displayName: displayName}
				gameId: gameId
				players: players

			$.services.matchService.validate newMatch, (err) ->
				return $.utils.onError done, err if err
				$.stores.submissionStore.create newSubmission, (err, submission) ->
					return $.utils.onError done, err if err

					me =
						type: 'submission'
						name: displayName
						userId: userId
						submissionId: submission.objectId

					newMatch =
						submitBy: {userId: userId, displayName: displayName}
						gameId: gameId
						players: _.map newMatch.players, (p) -> if p.type == 'me' then me else p

					$.stores.matchStore.create newMatch, (err, match) ->
						return $.utils.onError done, err if err
						$.stores.submissionStore.addMatchId submission.objectId, match.objectId, (err) ->
							return $.utils.onError done, err if err
							done null, match

	return self
