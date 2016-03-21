
module.exports = (grunt, options) ->
	config =
		dev:
			tasks: ['nodemon:dev', 'nodemon:worker', 'watch:dev', 'watch:devReload']
			options:
				logConcurrentOutput: true
				limit: 10

	return config
