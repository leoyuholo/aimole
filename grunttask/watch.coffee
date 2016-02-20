
module.exports = (grunt, options) ->
	config =
		options:
			spawn: false
			debounceDelay: 2000
		test:
			files: ['**/*.coffee', '!**/node_modules/**']
			tasks: ['coffeelint:all', 'mochaTest:all']
		dev:
			files: ['client/**']
			tasks: ['jade:dev']
		devReload:
			options:
				livereload: 35729
			files: ['public/**', 'public/.rebooted']

	return config
