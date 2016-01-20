gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

config = require './config'

gulp.task 'lint-coffee', () ->
	gulp.src config.files.coffee
		.pipe plugins.coffeelint
			optFile: 'coffeelint.json'
		.pipe plugins.coffeelint.reporter()

gulp.task 'lint-js', () ->
	gulp.src [].concat.apply config.files.js, config.files.jsx
		.pipe plugins.jshint()
		.pipe plugins.jshint.reporter()

gulp.task 'lint', ['lint-coffee', 'lint-js']
