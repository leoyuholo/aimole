
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'newMatch', (req, res) ->
			gameId = req.params.gameId
			players = req.params.players

			console.log 'newMatch', gameId, players

			res.success 'Not implemented yet.'
