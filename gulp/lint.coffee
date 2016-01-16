gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

listOfCoffee = ['*.coffee', 'server/**.coffee', 'config/**.coffee', 'test/**.coffee', 'glup/**.coffee']
listOfJs = []
listOfJsx = ['client/**.jsx']

gulp.task 'lint-coffee', () ->
	gulp.src listOfCoffee
		.pipe plugins.coffeelint {optFile: 'coffeelint.json'}
		.pipe plugins.coffeelint.reporter()

gulp.task 'lint-js', () ->
	gulp.src [].concat.apply listOfJs, listOfJsx
		.pipe plugins.jshint()
		.pipe plugins.jshint.reporter()

gulp.task 'lint', ['lint-coffee', 'lint-js']
