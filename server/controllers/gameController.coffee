
module.exports = ($) ->

	router = $.express.Router()

	router.get '/list', (req, res, done) ->

		$.services.gameService.list (err, games) ->

			res.json
				success: true
				games: games

	router.post '/submit', (req, res, done) ->
		
		code = req.body.code

		$.services.gameService.submit code, (err, gameResult) ->
			return $.utils.onError done, err if err

			res.json
				success: true
				gameResult: gameResult

	return router
