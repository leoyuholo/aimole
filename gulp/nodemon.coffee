child_process = require 'child_process'
exec = child_process.exec

gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

livereloadDelay = 2500

gulp.task 'nodemon', () ->
	plugins.nodemon
		verbose: true
		legacyWatch: true
		script: 'server/app.coffee'
		watch: ['server/', 'configs/']
		# ext: 'coffee'
		# tasks: ['lint']
		# ignore: []
		execMap:
			coffee: 'node_modules/.bin/coffee'
	.on 'restart', () ->
		setTimeout () ->
			gulp.src('server/app.coffee')
				.pipe(livereload())
		, livereloadDelay
