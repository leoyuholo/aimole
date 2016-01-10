path = require 'path'

gulp = require('gulp')
jshint = require('gulp-jshint')
coffeelint = require('gulp-coffeelint')
jade = require('gulp-jade')
exec = require('child_process').exec
nodemon = require('gulp-nodemon')
livereload = require('gulp-livereload')
browserify = require('browserify')
babelify = require('babelify')
fs = require('fs')

publicDir = path.join __dirname, 'public'

livereloadDelay = 2500

# List of coffee script / JSX for lint & watch
listOfCoffee = ['*.coffee', 'server/**.coffee', 'config/**.coffee', 'test/**.coffee']
listOfJs = ['client/**.jsx']

# Testing Travis
gulp.task('travis', () ->
	return
)

gulp.task('lint-coffee', () ->
	gulp.src(listOfCoffee)
		.pipe(coffeelint( {optFile: 'coffeelint.json'} ))
		.pipe(coffeelint.reporter())
)

# Lint for JavaScript and CoffeeScript
gulp.task('lint-js', () ->
	gulp.src(listOfJs)
		.pipe(jshint())
		.pipe(jshint.reporter())
)

# Compile JSX
gulp.task('jsx', () ->
	browserify(['client/**.jsx'])
		.transform(babelify)
		.bundle()
		.on('error', (err) -> console.log('Error: ', err.message))
		.pipe(source('bundle.js'))
		.pipe(gulp.dest(publicDir))
)

# Compile SASS
gulp.task('sass', () ->
	gulp.src('client/**.scss')
		.pipe(sass().on('error', sass.logError))
		.pipe(gulp.dest(publicDir))
)

# Copy HTML
gulp.task('html', () ->
	gulp.src(['client/**.html'])
		# .pipe(inject(gulp.src(['public/livereload.js'], {read: false})))
		.pipe(gulp.dest(publicDir))
		.pipe(livereload())
)

# Watch for changes
gulp.task('watch', () ->
	livereload.listen()
	# gulp.watch(['**/*.js', '**/*.jsx', '**/*.coffee'], ['lint'])
	gulp.watch(listOfJs, ['lint-js'])
	gulp.watch(listOfCoffee, ['lint-coffee'])
	gulp.watch('client/**.html', ['html'])
	# gulp.watch('**/*.scss', ['sass'])
)

# Simple server starter
gulp.task('node', () ->
	exec('coffee server/app.coffee', (err, stdout, stderr) ->
		console.log(stdout)
		console.log(stderr)
		console.error(err)
	)
)

# Start server with nodemon
gulp.task('nodemon', () ->
	nodemon(
		verbose: true
		legacyWatch: true
		script: 'server/app.coffee'
		watch: ['server/', 'configs/']
		# ext: 'coffee'
		# tasks: ['lint']
		# ignore: []
		execMap:
			coffee: 'node_modules/.bin/coffee'
	).on('restart', () ->
		setTimeout ( () ->
			gulp.src('server/app.coffee')
				.pipe(livereload())
		), livereloadDelay
	)
)

# Default task
gulp.task('default', ['html', 'watch', 'lint-js', 'lint-coffee', 'nodemon'])
