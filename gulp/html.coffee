path = require 'path'

gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

publicDir = path.join __dirname, 'public'

gulp.task 'html', () ->
	gulp.src ['client/**.html']
		.pipe plugins.inject gulp.src ['./bundle.js'], {read: false}
		.pipe plugins.injectString.before '</head>', '''
<script>document.write('<script src="http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1"></' + 'script>')</script>
		''' # For live reload
		.pipe gulp.dest publicDir
		.pipe plugins.livereload()
