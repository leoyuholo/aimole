path = require 'path'

module.exports = self = {}

self.rootDir = path.join __dirname, '..', '..'
self.serverDir = path.join self.rootDir, 'server'

self.getScriptPath = (args...) ->
	path.join self.serverDir, args...

self.getRootPath = (args...) ->
	path.join self.rootDir, args...
