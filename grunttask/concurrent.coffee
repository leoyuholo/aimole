
module.exports = (grunt, options) ->
	config =
		dev:
			tasks: ['nodemon:dev', 'watch:dev', 'watch:livereload']
			options:
				logConcurrentOutput: true
				limit: 10

	return config
