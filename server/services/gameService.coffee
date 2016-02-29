path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	readAiCode = (installInfo, done) ->
		async.map installInfo.gameConfig.ai, ( (ai, done) ->
			aiPath = path.join installInfo.cloneToPath, ai.file
			fse.readFile aiPath, {encoding: 'utf8'}, (err, aiCode) ->
				return $.utils.onError done, err if err

				ai.type = 'ai'
				ai.code = aiCode

				done null, ai
		), (err, aiList) ->
			return $.utils.onError done, err if err

			installInfo.gameConfig.ai = aiList

			done null

	readVerdictCode = (installInfo, done) ->
		verdictPath = path.join installInfo.cloneToPath, installInfo.gameConfig.verdict.file
		fse.readFile verdictPath, {encoding: 'utf8'}, (err, verdictCode) ->
			return $.utils.onError done, err if err

			installInfo.gameConfig.verdict.code = verdictCode

			done null

	readGameConfig = (installInfo, done) ->
		fse.readJson installInfo.gameConfigPath, {encoding: 'utf8'}, (err, gameConfig) ->
			return $.utils.onError done, err if err

			installInfo.gameConfig = gameConfig

			done null

	self.install = (url, done) ->
		tmpId = $.utils.rng.generateId()
		cloneToPath = path.join $.tmpDir, 'git', tmpId
		installInfo =
			url: url
			tmpId: 'tmpId'
			cloneToPath: cloneToPath
			gameConfigPath: path.join cloneToPath, 'aimole.json'

		async.series [
			_.partial $.utils.git.clone, installInfo.url, installInfo.cloneToPath
			_.partial readGameConfig, installInfo
			_.partial readVerdictCode, installInfo
			_.partial readAiCode, installInfo
		], (err) ->
			return $.utils.onError done, err if err

			done null, installInfo.gameConfig

	return self
