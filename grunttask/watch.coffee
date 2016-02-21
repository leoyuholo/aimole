
module.exports = (grunt, options) ->
	config =
		options:
			spawn: true
			debounceDelay: 2000
		test:
			files: ['**/*.coffee', '!**/node_modules/**']
			tasks: ['mochaTest:all']
		dev:
			files: ['client/**']
			tasks: ['jade:dev']
		devReload:
			options:
				livereload: 35729
			files: ['public/**', 'public/.rebooted']

	return config
