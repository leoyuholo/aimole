
module.exports = (grunt, options) ->
	config =
		options:
			execMap:
				coffee: 'node_modules/.bin/coffee'
		dev:
			script: 'server/app.coffee'
			options:
				watch: ['server/', 'configs/config']

	return config
