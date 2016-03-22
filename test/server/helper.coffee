path = require 'path'
util = require 'util'

async = require 'async'
DatabaseCleaner = require 'database-cleaner'
mongodb = require 'mongodb'

module.exports = self = {}

self.rootDir = path.join __dirname, '..', '..'
self.serverDir = path.join self.rootDir, 'server'

self.getScriptPath = (args...) ->
	path.join self.serverDir, args...

self.getRootPath = (args...) ->
	path.join self.rootDir, args...

$ = (require self.getScriptPath 'globals') {}
self.getGlobals = () ->
	return $

serverRunning = false
self.setupServer = ($, done) ->
	return done null if serverRunning

	async.series [
		$.run.setup
		$.run.server
		$.run.parseSchemaSetup
	], (err) ->
		return done err if err
		serverRunning = true
		done null

self.cleanDB = (done) ->
	databaseCleaner = new DatabaseCleaner('mongodb')

	mongodb.connect "mongodb://#{$.config.mongodb.host}:#{$.config.mongodb.port}/#{$.config.mongodb.db}", (err, db) ->
		return done err if err
		databaseCleaner.clean db, () ->
			console.log 'Database cleaned.'
			db.close()
			done null

self.inspect = (obj) ->
	util.inspect obj, {showHidden: false, depth: null}
