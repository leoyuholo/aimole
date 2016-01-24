path = require 'path'
babelify = require 'babelify'

module.exports =
	publicDir: 'public/'
	files:
		coffee: ['*.coffee', 'server/**.coffee', 'config/**.coffee', 'test/**.coffee', 'gulp/**.coffee']
		js: ['client/**.jsx']
		jsx: ['client/**.jsx']
		html: ['client/**.html']
		mocha: ['test/server/**/*Test.coffee', 'test/games/**/*Test.coffee']
	inject: ['bundle.js', 'main.css']
	livereload:
		port: 32759
	nodemon:
		legacyWatch: true
		script: 'server/app.coffee'
		watch: ['server/', 'configs/']
		ext: 'coffee'
		# tasks: ['lint']
		# ignore: []
		execMap:
			coffee: 'node_modules/.bin/coffee'
		livereloaddelay: 2500
	browserify:
		entries: ['client/jsx/App.jsx']
		paths: ['client/jsx/']
		transform: [babelify]
		insertGlobals: true
		outputName: 'bundle.js'
	mocha:
		timeout: 5000
		require: ['coffee-errors']
