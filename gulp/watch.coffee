gulp = require 'gulp'
plugins = require('gulp-load-plugins')()

listOfCoffee = ['*.coffee', 'server/**.coffee', 'config/**.coffee', 'test/**.coffee', 'gulp/**.coffee']
listOfJs = ['client/**.jsx']
listOfJsx = ['client/**.jsx']

gulp.task 'watch', () ->
	plugins.livereload.listen()
	gulp.watch listOfJs, ['lint-js']
	gulp.watch listOfCoffee, ['lint-coffee']
	gulp.watch listOfJsx, ['browserify']
	gulp.watch 'client/**.html', ['html']
	# gulp.watch('**/*.scss', ['sass'])
