path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	# TODO: validate

	readCodeTpl = (cloneToPath, info, done) ->
		return done null if !cloneToPath || !info?.gameConfig?.codeTpl || !_.isObject info.gameConfig.codeTpl

		async.forEachOf info.gameConfig.codeTpl, ( (file, language, done) ->
			fse.readFile path.join(cloneToPath, file), {encoding: 'utf8'}, (err, codeTpl) ->
				return $.utils.onError done, err if err

				info.gameConfig.codeTpl[language] = codeTpl

				done null, codeTpl
		), (err) ->
			return $.utils.onError done, err if err

			done null, info.gameConfig.codeTpl

	readAiCode = (cloneToPath, info, done) ->
		return $.utils.onError done, new Error('Error reading AI code.') if !cloneToPath || !info?.gameConfig?.ai || !_.isArray info.gameConfig.ai

		async.map info.gameConfig.ai, ( (aiConfig, done) ->
			return $.utils.onError done, new Error('Missing AI file.') if !aiConfig.file

			fse.readFile path.join(cloneToPath, aiConfig.file), {encoding: 'utf8'}, (err, code) ->
				return $.utils.onError done, err if err

				aiConfig.code = code
				aiConfig.type = 'ai'

				done null, aiConfig
		), (err, aiList) ->
			return $.utils.onError done, err if err

			info.gameConfig.ai = aiList

			done null, aiList

	readVerdictCode = (cloneToPath, info, done) ->
		return $.utils.onError done, new Error('Error reading verdict code.') if !cloneToPath && !info?.gameConfig?.verdict?.file
		fse.readFile path.join(cloneToPath, info.gameConfig.verdict.file), {encoding: 'utf8'}, (err, verdictCode) ->
			return $.utils.onError done, err if err

			info.gameConfig.verdict.code = verdictCode

			done null

	readGameConfig = (cloneToPath, info, done) ->
		return $.utils.onError done, new Error('Error reading game config') if !cloneToPath
		fse.readJson path.join(cloneToPath, 'aimole.json'), {encoding: 'utf8'}, (err, gameConfig) ->
			return $.utils.onError done, err if err

			info.gameConfig = gameConfig

			done null

	self.readGame = (url, done) ->
		cloneToPath = path.join $.tmpDir, 'git', $.utils.rng.generateId()
		info = {}

		async.series [
			_.partial $.utils.git.clone, url, cloneToPath
			_.partial readGameConfig, cloneToPath, info
			_.partial readVerdictCode, cloneToPath, info
			_.partial readAiCode, cloneToPath, info
			_.partial readCodeTpl, cloneToPath, info
			_.partial fse.remove, cloneToPath
		], (err) ->
			return $.utils.onError done, err if err

			done null, info.gameConfig

	return self
