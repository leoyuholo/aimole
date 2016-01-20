gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

config = require './config'

gulp.task 'watch', () ->
	plugins.livereload.listen config.livereload.port
	gulp.watch config.files.jsx, ['browserify']
	gulp.watch config.files.html, ['html']
	# gulp.watch config.files.js, ['lint-js']
	# gulp.watch config.files.coffee, ['lint-coffee']
	# gulp.watch('**/*.scss', ['sass'])
