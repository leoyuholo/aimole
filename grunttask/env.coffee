
module.exports = (grunt, options) ->
	config =
		test:
			NODE_ENV: 'testing'
		dev:
			NODE_ENV: 'development'

	return config
