$ = require '../globals'

router = $.express.Router()

router.get '/list', (req, res, done) ->

	res.json
		success: true
		games: [
			{
				name: 'tic-tac-toe'
				difficulty: 'easy'
			},
			{
				name: '2048'
				difficulty: 'intermediate'
			}
		]

module.exports = router
