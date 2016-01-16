path = require 'path'

gulp = require 'gulp'
plugins = require('gulp-load-plugins')()
# browserify = require 'browserify'
# reactify = require 'reactify'
# source = require 'vinyl-source-stream'
# buffer = require 'vinyl-buffer'

publicDir = path.join __dirname, 'public'

gulp.task 'browserify', () -> return
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
