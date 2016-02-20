path = require 'path'

fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	self.serverStarted = () ->
		fse.writeFile path.join($.publicDir, '.rebooted'), 'rebooted'
	$.emitter.on 'serverStarted', self.serverStarted if $.env.development && !$.env.worker

	return self
