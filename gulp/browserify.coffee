path = require 'path'

gulp = require 'gulp'
plugins = require('gulp-load-plugins')()
browserify = require 'browserify'
babelify = require 'babelify'
# reactify = require 'reactify'
source = require 'vinyl-source-stream'
# buffer = require 'vinyl-buffer'

publicDir = path.join __dirname, 'public'

gulp.task 'browserify', () ->
	browserify(['client/jsx/App.jsx'], {
		paths: ['client/jsx/']
	})
	.transform(babelify)
	.bundle()
	.on('error', (err) -> console.log('Error: ', err.message))
	.pipe(source('bundle.js'))
	.pipe(gulp.dest('public/'))

	# browserify
	# 	entries: 'client/index.jsx'
	# 	debug: true
	# 	transform: [reactify]
	# .bundle()
	# .pipe source 'client/index.jsx'
	# .pipe buffer()
	# .pipe plugins.sourcemaps.init
	# 	loadMaps: true
	# .pipe(plugins.uglify())
	# .pipe(plugins.sourcemaps.write './')
	# .pipe(gulp.dest(publicDir))
