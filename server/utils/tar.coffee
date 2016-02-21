childProcess = require 'child_process'
path = require 'path'

_ = require 'lodash'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	self.targz = (src, dst, done) ->
		fse.ensureDir path.dirname(dst), (err) ->
			return $.utils.onError done, err if err
			childProcess.exec "tar czf #{dst} -C #{src} .", _.unary done

	self.untargz = (src, dst, done) ->
		fse.ensureDir dst, (err) ->
			return $.utils.onError done, err if err
			childProcess.exec "tar xf #{src} -C #{dst}", _.unary done

	return self
