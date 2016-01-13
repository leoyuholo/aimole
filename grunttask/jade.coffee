
module.exports = (grunt, options) ->
	config =
		dev:
			options:
				pretty: true
			files:
				'public/index.html': 'client/index.jade'

	return config
