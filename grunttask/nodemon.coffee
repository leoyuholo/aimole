
module.exports = (grunt, options) ->
	config =
		options:
			execMap:
				coffee: 'node_modules/.bin/coffee'
		dev:
			script: 'server/app.coffee'
			options:
				watch: ['server/', 'configs/']
		worker:
			script: 'server/worker.coffee'
			options:
				watch: ['server/', 'configs/']

	return config
