
module.exports = (grunt, options) ->
	config =
		options:
			spawn: false
			debounceDelay: 2000
		test:
			options:
				forever: false
			files: ['test/games/**/*Test.coffee', 'test/server/**/*Test.coffee', 'server/**/*.coffee']
			tasks: ['coffeelint:all', 'mochaTest:all']
		dev:
			files: ['client/**']
			tasks: ['jade:dev', 'replace:dev']
		livereload:
			options:
				livereload: grunt.option('livereload') || 35729
			files: ['public/**', 'public/.rebooted']

	grunt.event.on 'watch', (action, filepath, target) ->
		grunt.config 'coffeelint.all.src', filepath
		if filepath.match /Test\.coffee$/
			grunt.config 'mochaTest.all.src', filepath
		else
			testFilepath = 'test/' + filepath.replace /\.coffee$/, 'Test.coffee'
			grunt.config 'mochaTest.all.src', testFilepath
		return true

	return config
