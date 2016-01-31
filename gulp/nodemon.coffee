gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

config = require './config'

gulp.task 'nodemon', () ->
	plugins.nodemon
		legacyWatch: true
		script: 'server/app.coffee'
		watch: ['server/', 'configs/']
		ext: 'coffee'
		# tasks: ['lint']
		# ignore: []
		execMap:
			coffee: 'node_modules/.bin/coffee'
		livereloaddelay: 2500
	.on 'restart', () ->
		setTimeout () ->
			gulp.src 'server/app.coffee'
				.pipe livereload()
		, config.nodemon.livereloaddelay
