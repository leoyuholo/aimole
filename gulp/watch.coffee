gulp = require 'gulp'
plugins = require('gulp-load-plugins')()
watch = require 'gulp-watch'

config = require './config'

gulp.task 'watch', () ->
	plugins.livereload.listen config.livereload.port
	watch config.files.jsx, () -> gulp.start 'browserify'
	watch config.files.html, () -> gulp.start 'html'
	# gulp.watch config.files.js, ['lint-js']
	# gulp.watch config.files.coffee, ['lint-coffee']
	# gulp.watch('**/*.scss', ['sass'])
