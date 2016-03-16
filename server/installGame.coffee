path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'

$ = require('./globals') {}

githubUrl = process.argv[2]

if !githubUrl
	console.log 'usage: coffee runGame.coffee https://github.com/leoyuholo/aimole.git'
	process.exit 0

installGame = (githubUrl, done) ->
	$.services.adminService.readGame githubUrl, (err, gameConfig) ->
		return done err if err

		game =
			githubUrl: githubUrl
			name: gameConfig.name
			description: gameConfig.description
			author: gameConfig.author
			version: gameConfig.version
			viewUrl: gameConfig.viewUrl
			players: gameConfig.players
			ai: gameConfig.ai
			verdict: gameConfig.verdict

		async.series [
			_.partial async.waterfall, [
				_.partial $.stores.gameStore.upsertByGithubUrl, githubUrl, game
				(game, done) ->
					$.stores.cacheStore.upsert "game-#{game.objectId}", $.models.Game.envelop(game), done
			]
			_.partial async.waterfall, [
				$.stores.gameStore.list
				(games, done) ->
					$.stores.cacheStore.upsert 'games', _.map(games, $.models.Game.envelop), done
			]
		], done

async.series [
	$.run.setup
	_.partial installGame, githubUrl
], (err) ->
	if err
		console.log "error installing game [#{githubUrl}]: #{err.message} Please make sure aimole web server is running"
		return process.exit 0

	console.log "game [#{githubUrl}] installed."
	return process.exit 0
