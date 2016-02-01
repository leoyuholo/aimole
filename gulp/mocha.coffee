gulp = require 'gulp'
plugins = require('gulp-load-plugins')()
require 'coffee-script/register'

config = require './config'

gulp.task 'mocha', () ->
	gulp.src(config.files.mocha, {read: false})
	.pipe plugins.mocha
		timeout: 5000
		require: ['coffee-errors']
	.on 'error', plugins.util.log
	.once 'end', () -> process.exit()
