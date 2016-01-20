gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

config = require './config'

gulp.task 'nodemon', () ->
	plugins.nodemon config.nodemon
	.on 'restart', () ->
		setTimeout () ->
			gulp.src 'server/app.coffee'
				.pipe livereload()
		, config.nodemon.livereloaddelay
