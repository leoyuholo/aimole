path = require 'path'
babelify = require 'babelify'

module.exports =
	publicDir: 'public/'
	files:
		coffee: ['*.coffee', 'server/**.coffee', 'config/**.coffee', 'test/**.coffee', 'gulp/**.coffee']
		js: ['client/**/*.js']
		jsx: ['client/jsx/**/*.jsx']
		html: ['client/**.html']
		mocha: ['test/server/**/*Test.coffee', 'test/games/**/*Test.coffee']
	livereload:
		port: 32759
