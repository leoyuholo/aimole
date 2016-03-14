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

		$.stores.gameStore.upsertByGithubUrl githubUrl, game, done

async.series [
	$.run.setup
	$.run.server
	_.partial installGame, githubUrl
], (err) ->
	if err
		console.log "error installing game [#{githubUrl}]: #{err.message}"
		return process.exit 0

	console.log "game [#{githubUrl}] installed."
	process.exit 0
