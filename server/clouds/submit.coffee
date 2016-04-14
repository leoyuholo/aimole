
_ = require 'lodash'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'submit', (req, res) ->
			userId = req.user?.id
			displayName = req.user?.get? 'displayName'
			gameId = req.params.gameId
			language = req.params.language || 'c'
			code = req.params.code
			ranked = req.params.ranked
			players = req.params.players

			return res.error 'Anonymous users are not allowed to submit code.' if !userId || !displayName
			return res.error 'Missing game id.' if !gameId
			return res.error 'Missing code.' if !code
			return res.error 'Missing players.' if !ranked && (!players || players.length == 0)

			newSubmission =
				userId: userId
				displayName: displayName
				gameId: gameId
				language: language
				code: code

			# TODO: avoid running multiple matches for same user at the same time, related to rankingService.coffee

			submit = _.partial $.services.submissionService.rank, newSubmission
			submit = _.partial $.services.submissionService.try, newSubmission, players if !ranked
			submit (err, match) ->
				return res.error err.message if err
				res.success $.models.Match.envelop match
