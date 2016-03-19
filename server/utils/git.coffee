childProcess = require 'child_process'

module.exports = ($) ->
	self = {}

	self.clone = (url, cloneToPath, done) ->
		return done new Error('Missing url for git clone.') if !url
		return done new Error('Missing target directory for git clone.') if !cloneToPath

		childProcess.exec "git clone #{url} #{cloneToPath}", (err) ->
			return done err if err
			done null

	return self
