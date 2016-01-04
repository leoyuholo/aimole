$ = require '../globals'

router = $.express.Router()

router.get '/login', (req, res, done) ->

	res.json
		success: true
		user:
			email: 'demo@aimole.com'
			username: 'demo'

module.exports = router
