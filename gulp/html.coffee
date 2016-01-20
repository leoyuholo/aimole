gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

config = require './config'

gulp.task 'html', () ->
	gulp.src config.files.html
		.pipe plugins.inject gulp.src config.inject, {read: false, cwd: 'public'}
		.pipe plugins.injectString.before '</head>', """
<script>document.write('<script src="http://' + (location.host || 'localhost').split(':')[0] + ':#{config.livereload.port}/livereload.js?snipver=1"></' + 'script>')</script>
		""" # For live reload
		.pipe gulp.dest config.publicDir
		.pipe plugins.livereload()
