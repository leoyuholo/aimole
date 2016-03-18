
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'newMatch', (req, res) ->
			userId = req.user?.id || 'anonymous'
			displayName = req.user?.get? 'displayName' || 'Anonymous'
			gameId = req.params.gameId
			players = req.params.players

			newMatch =
				submitBy: {userId: userId, displayName: displayName}
				gameId: gameId
				players: players

			$.services.matchService.create newMatch, (err, match) ->
				return res.error err.message if err
				res.success match.objectId
