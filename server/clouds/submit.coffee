
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'submit', (req, res) ->
			userId = req.user?.id
			displayName = req.user?.get? 'displayName'
			gameId = req.params.gameId
			language = req.params.language || 'c'
			code = req.params.code
			players = req.params.players

			return res.error 'Anonymous user is not allowed to submit code.' if !userId || !displayName
			return res.error 'Missing game id.' if !gameId
			return res.error 'Missing code.' if !code
			return res.error 'Missing players.' if !players

			$.services.submissionService.submit gameId, userId, displayName, language, code, players, (err, match) ->
				return res.error err.message if err
				res.success match.objectId
