
module.exports = (grunt, options) ->
	config =
		options:
			spawn: false
			debounceDelay: 2000
		dev:
			files: ['client/**']
			tasks: ['jade:dev', 'replace:dev']
		livereload:
			options:
				livereload: grunt.option('livereload') || 35729
			files: ['public/**', 'public/.rebooted']

	return config
