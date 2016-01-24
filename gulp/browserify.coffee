gulp = require 'gulp'
plugins = require('gulp-load-plugins')()
source = require 'vinyl-source-stream'
browserify = require 'browserify'
# reactify = require 'reactify'

config = require './config'

gulp.task 'browserify', () ->
	browserify config.browserify
	.bundle()
	.on 'error', (err) -> console.log 'Error in browserify: ', err.message
	.pipe source config.browserify.outputName
	.pipe gulp.dest config.publicDir
