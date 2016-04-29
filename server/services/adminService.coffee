path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	validate = (game) ->
		languages = $.constants.language.names
		rankingSchemes = ['max', 'elo', 'podium']

		throw new Error('Missing game.') if !game

		throw new Error('Missing githubUrl.') if !game.githubUrl
		throw new Error('GithubUrl is not a string.') if !_.isString game.githubUrl

		throw new Error('Missing name.') if !game.name
		throw new Error('Name is not a string.') if !_.isString game.name

		throw new Error('ViewUrl is not a valid url.') if !_.isString game.viewUrl
		throw new Error('BgUrl is not a string.') if !_.isString game.bgUrl

		throw new Error('Missing number of players.') if !game.players
		throw new Error('Players is not a number.') if !_.isNumber game.players

		throw new Error('Missing ranking.') if !game.ranking
		throw new Error('Missing ranking scheme.') if !game.ranking.scheme
		throw new Error('Ranking scheme must be one of max, elo or podium.') if !_.includes rankingSchemes, game.ranking.scheme
		throw new Error('Ranking baseScore is not a number.') if !_.isNumber game.ranking.baseScore

		throw new Error('Missing default AI.') if !game.ai
		throw new Error('AI is not an array.') if !_.isArray game.ai
		throw new Error('AI is empty.') if game.ai.length == 0
		throw new Error('AI names are not unique.') if game.ai.length != _.uniqBy(game.ai, 'name').length

		_.each game.ai, (ai) ->
			throw new Error('Missing ai type.') if !ai.type
			throw new Error('AI type is not a string.') if !_.isString ai.type

			throw new Error('Missing ai name.') if !ai.name
			throw new Error('AI name is not a string.') if !_.isString ai.name

			throw new Error("AI language #{ai.language} of #{ai.name} is not one of #{languages}.") if ai.language && !_.includes languages, ai.language

			throw new Error('Missing ai code.') if !ai.code
			throw new Error('AI code is not a string.') if !_.isString ai.code

		if game.codeTpl
			throw new Error() if !_.isObject game.codeTpl
			_.each game.codeTpl, (tpl, language) ->
				throw new Error("Code template language #{language} is not one of #{languages}.") if !_.includes languages, language
				throw new Error("Code template for language #{language} is not a string.") if !_.isString tpl

		throw new Error('Missing verdict.') if !game.verdict
		throw new Error("AI language is not one of #{languages}.") if game.verdict.language && !_.includes languages, game.verdict.language
		throw new Error('Verdict timeLimit is not a number.') if game.verdict.timeLimit && !_.isNumber game.verdict.timeLimit

	self.installGame = (gameConfig, done) ->
		try
			validate gameConfig
		catch err
			return $.utils.onError done, err

		addAiProfiles = (game, done) ->
			return done null if game.players < 2
			async.each game.ai, ( (ai, done) ->
				profile =
					gameId: game.objectId
					userId: "ai_#{game.objectId}_#{ai.name}"
					displayName: ai.name
					pictureUrl: ''
					ai: true
					score: game.ranking.baseScore
				$.services.profileService.addIfNotExist profile, done
			), done

		updateGameCache = (game, done) ->
			$.stores.cacheStore.upsert "game-#{game.objectId}", $.models.Game.envelop(game), done

		updateGamesCache = (game, done) ->
			async.waterfall [
				$.stores.gameStore.list
				(games, done) -> $.stores.cacheStore.upsert 'games', _.map(games, $.models.Game.envelop), done
			], done

		$.stores.gameStore.upsertByGithubUrl gameConfig.githubUrl, gameConfig, (err, game) ->
			return $.utils.onError done, err if err
			async.applyEach [addAiProfiles, updateGameCache, updateGamesCache], game, (err) ->
				return $.utils.onError done, err if err
				done null, game

	readCodeTpl = (gamePath, info, done) ->
		return done null if !gamePath || !info?.gameConfig?.codeTpl || !_.isObject info.gameConfig.codeTpl

		async.forEachOf info.gameConfig.codeTpl, ( (file, language, done) ->
			fse.readFile path.join(gamePath, file), {encoding: 'utf8'}, (err, codeTpl) ->
				return $.utils.onError done, err if err

				info.gameConfig.codeTpl[language] = codeTpl

				done null, codeTpl
		), (err) ->
			return $.utils.onError done, err if err

			done null, info.gameConfig.codeTpl

	readAiCode = (gamePath, info, done) ->
		return $.utils.onError done, new Error('Error reading AI code.') if !gamePath || !info?.gameConfig?.ai || !_.isArray info.gameConfig.ai

		async.map info.gameConfig.ai, ( (aiConfig, done) ->
			return $.utils.onError done, new Error('Missing AI file.') if !aiConfig.file

			fse.readFile path.join(gamePath, aiConfig.file), {encoding: 'utf8'}, (err, code) ->
				return $.utils.onError done, err if err

				aiConfig.code = code
				aiConfig.type = 'ai'

				done null, aiConfig
		), (err, aiList) ->
			return $.utils.onError done, err if err

			info.gameConfig.ai = aiList

			done null, aiList

	readVerdictCode = (gamePath, info, done) ->
		return $.utils.onError done, new Error('Error reading verdict code. Missing gamePath.') if !gamePath
		return $.utils.onError done, new Error('Error reading verdict code. Missing verdict file path.') if !info?.gameConfig?.verdict?.file
		fse.readFile path.join(gamePath, info.gameConfig.verdict.file), {encoding: 'utf8'}, (err, verdictCode) ->
			return $.utils.onError done, err if err

			info.gameConfig.verdict.code = verdictCode

			done null

	readGameConfig = (gamePath, info, done) ->
		return $.utils.onError done, new Error('Error reading game config. Missing gamePath.') if !gamePath
		fse.readJson path.join(gamePath, 'aimole.json'), {encoding: 'utf8'}, (err, gameConfig) ->
			return $.utils.onError done, err if err

			gameConfig.githubUrl = info.githubUrl
			info.gameConfig = gameConfig

			done null

	self.readGame = (url, done) ->
		gamePath = path.join $.tmpDir, 'git', $.utils.rng.generateId()
		info = {githubUrl: url}

		async.series [
			_.partial $.utils.git.clone, url, gamePath
			_.partial readGameConfig, gamePath, info
			_.partial readVerdictCode, gamePath, info
			_.partial readAiCode, gamePath, info
			_.partial readCodeTpl, gamePath, info
			_.partial fse.remove, gamePath
		], (err) ->
			return $.utils.onError done, err if err

			done null, info.gameConfig

	return self
