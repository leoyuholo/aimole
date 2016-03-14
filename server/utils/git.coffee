
NodeGit = require 'nodegit'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	self.clone = (url, cloneToPath, done) ->
		return done new Error('Missing url for git clone.') if !url
		return done new Error('Missing target directory for git clone.') if !cloneToPath

		NodeGit.Clone url, cloneToPath
			.then () -> done null
			.catch (err) -> done err

	return self
