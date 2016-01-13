
module.exports = ($) ->

	router = $.express.Router()

	router.get '/list', (req, res, done) ->

		$.services.gameService.list (err, games) ->

			res.json
				success: true
				games: games

	return router
