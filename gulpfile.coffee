path = require 'path'
fs = require('fs')
child_process = require('child_process')
exec = child_process.exec

gulp = require('gulp')
jshint = require('gulp-jshint')
coffeelint = require('gulp-coffeelint')
jade = require('gulp-jade')
nodemon = require('gulp-nodemon')
livereload = require('gulp-livereload')
browserify = require('browserify')
babelify = require('babelify')

watch = require('gulp-watch')
source = require('vinyl-source-stream')

publicDir = path.join __dirname, 'public'

# List of coffee script / JSX for lint & watch
listOfCoffee = ['*.coffee', 'server/**.coffee', 'config/**.coffee', 'test/**.coffee']
listOfJs = ['client/**.jsx']

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
	browserify(['client/jsx/App.jsx'], {
			paths: ['client/jsx/']
		})
		.transform(babelify)
		.bundle()
		.on('error', (err) -> console.log('Error: ', err.message))
		.pipe(source('bundle.js'))
		.pipe(gulp.dest(publicDir))
)

# Copy HTML
gulp.task('html', () ->
	gulp.src(['client/**.html', 'client/**.css'])
		# .pipe(inject(gulp.src(['public/livereload.js'], {read: false})))
		.pipe(gulp.dest(publicDir))
		.pipe(livereload())
)

# Watch for changes
gulp.task('watch', () ->
	livereload.listen()
	# gulp.watch(['**/*.js', '**/*.jsx', '**/*.coffee'], ['lint'])
	# gulp.watch(listOfJs, ['lint-js'])
	# gulp.watch(listOfCoffee, ['lint-coffee'])
	# gulp.watch('client/**.html', ['html'])
	watch(['**/*.js', 'client/jsx/**/.jsx', '**/*.coffee'], (files) ->
		gulp.start('lint')
	)
	# watch('**/*.js', (files) ->
	# 	gulp.start('lint-js')
	# )
	watch '**/*.coffee', (files) -> gulp.start('lint-coffee')
	watch 'client/**.html', (files) -> gulp.start('html')
	watch 'client/jsx/**/*.jsx', (files) -> gulp.start('jsx')
	# gulp.watch('**/*.scss', ['sass'])
)

# Start server with nodemon
livereloadDelay = 2500

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

gulp.task('travis', [])

gulp.task('dev', ['jsx', 'html', 'watch', 'lint-js', 'lint-coffee', 'nodemon'])

# Default task
gulp.task('default', ['dev'])
