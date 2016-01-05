path = require 'path'

module.exports = self = {}

rootdir = path.join __dirname, '..', '..'
self.getScriptPath = (relativePathToServer) ->
	path.join rootdir, 'server', relativePathToServer

self.getGlobalsStub = () ->
	require self.getScriptPath 'globals'
