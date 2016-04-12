
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'viewMatch', (req, res) ->
			userId = req.user?.id || 'anonymous'
			displayName = req.user?.get? 'displayName' || 'Anonymous'
			gameId = req.params.gameId
			players = req.params.players

			matchInfo =
				submitBy:
					userId: userId
					displayName: displayName
					ranked: false
				gameId: gameId
				players: players

			$.services.matchService.viewMatch matchInfo, (err, match) ->
				return res.error err.message if err
				res.success $.models.Match.envelop match
