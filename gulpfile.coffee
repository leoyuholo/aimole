path = require 'path'

gulp = require('gulp')
jshint = require('gulp-jshint')
coffeelint = require('gulp-coffeelint')
jade = require('gulp-jade')
exec = require('child_process').exec
nodemon = require('gulp-nodemon')
browserify = require('browserify')
babelify = require('babelify')

publicDir = path.join __dirname, 'public'

# Testing Travis
gulp.task('travis', () ->
	return
)

# Lint for JavaScript and CoffeeScript
gulp.task('lint', () ->
	gulp.src(['**/*.js', '!node_modules/**/*.js', '!client/public/**/*.js',
			'**/*.jsx', '!node_modules/**/*.jsx'])
		.pipe(jshint())
		.pipe(jshint.reporter())
	gulp.src(['**/*.coffee', '!node_modules/**/*.coffee'])
		.pipe(coffeelint( {optFile: 'coffeelint.json'} ))
		.pipe(coffeelint.reporter())
)

# Compile JSX
gulp.task('jsx', () ->
	browserify(['client/**/*.jsx'])
		.transform(babelify)
		.bundle()
		.on('error', (err) -> console.log('Error: ', err.message))
		.pipe(source('bundle.js'))
		.pipe(gulp.dest(publicDir))
)

# Compile SASS
gulp.task('sass', () ->
	gulp.src('client/**/*.scss')
		.pipe(sass().on('error', sass.logError))
		.pipe(gulp.dest(publicDir))
)

# Copy HTML
gulp.task('html', () ->
	gulp.src(['client/**/*.html'])
		.pipe(gulp.dest(publicDir))
)

# Watch for changes
gulp.task('watch', () ->
	gulp.watch(['**/*.js', '**/*.jsx', '**/*.coffee'], ['lint'])
	gulp.watch('**/*.scss', ['sass'])
)

# Start docker
gulp.task('node', () ->
	exec('coffee server/app.coffee', (err, stdout, stderr) ->
		console.log(stdout)
		console.log(stderr)
		console.error(err)
	)
)

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
		console.log('Restart')
	)
)

# Default task
gulp.task('default', ['html', 'lint', 'nodemon'])
