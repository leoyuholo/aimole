path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'
NodeGit = require 'nodegit'

module.exports = ($) ->
	self = {}

	readGameConfig = (installInfo, done) ->
		fse.readJson installInfo.gameConfigPath, {encoding: 'utf8'}, (err, gameConfig) ->
			return $.utils.onError done, err if err

			installInfo.gameConfig = gameConfig

			done null

	tarGame = (installInfo, done) ->
		$.utils.tar.targz installInfo.cloneToPath, installInfo.tarFilePath, done

	gitClone = (installInfo, done) ->
		NodeGit.Clone installInfo.url, installInfo.cloneToPath
			.then () -> done null
			.catch (err) -> done err

	self.install = (url, done) ->
		tmpId = $.utils.rng.generateId()
		cloneToPath = path.join $.tmpDir, 'git', tmpId
		installInfo =
			url: url
			tmpId: tmpId
			cloneToPath: cloneToPath
			gameConfigPath: path.join cloneToPath, 'aimole.json'
			tarFilePath: path.join $.tmpDir, 'gametar', "#{tmpId}.tar.gz"

		async.series [
			_.partial gitClone, installInfo
			_.partial readGameConfig, installInfo
			_.partial tarGame, installInfo
		], (err) ->
			return $.utils.onError done, err if err
			done null, installInfo

	return self
