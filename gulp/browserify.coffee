gulp = require 'gulp'
plugins = require('gulp-load-plugins')()
source = require 'vinyl-source-stream'
browserify = require 'browserify'
babelify = require 'babelify'

config = require './config'

gulp.task 'browserify', () ->
	browserify
		entries: ['client/jsx/App.jsx']
		transform: [[babelify, {presets: ['react', 'es2015']}]]
		paths: ['client/jsx/']
		insertGlobals: true
	.bundle()
	.on 'error', (err) -> console.log 'Error in browserify: ', err.message
	.pipe source 'bundle.js'
	.pipe gulp.dest config.publicDir
