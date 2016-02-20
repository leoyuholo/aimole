
module.exports = (grunt, options) ->
	config =
		dev:
			tasks: ['nodemon:dev', 'watch:dev', 'watch:devReload']
			options:
				logConcurrentOutput: true

	return config
