gulp = require 'gulp'
plugins = require('gulp-load-plugins')()
require 'coffee-script/register'

config = require './config'

gulp.task('mocha', () ->
	gulp.src(config.files.mocha, {read: false})
	.pipe(plugins.mocha config.mocha)
)
