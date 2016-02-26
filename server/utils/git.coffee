
NodeGit = require 'nodegit'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	self.clone = (url, cloneToPath, done) ->
		NodeGit.Clone url, cloneToPath
			.then () -> done null
			.catch (err) -> done err

	return self
