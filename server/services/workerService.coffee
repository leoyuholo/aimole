path = require 'path'

_ = require 'lodash'
fse = require 'fs-extra'
async = require 'async'

module.exports = ($) ->
	self = {}

	gameCache = {}

	self.runGame = (gameInfo, done) ->
		gameInfo.verdictConfig = gameInfo.game.gameConfig.verdict
		async.map gameInfo.players, ( (player, done) ->
			return done null, _.find gameInfo.game.gameConfig.ai, {name: player.name} if player.type == 'ai'
			(new $.Parse.Query($.models.Submission)).get player.submissionId
				.then (submission) -> done null, submission
				.fail done new Error("Submission #{player.submissionId} not found.")
		), (err, players) ->
			return $.utils.onError done, err if err

			gameInfo.playerConfigs = players

			$.services.sandboxService.runGame gameInfo.verdictConfig, gameInfo.playerConfigs, done

	self.findGame = (gameObjectId, done) ->
		(new $.Parse.Query($.models.Game)).get gameObjectId
			.then (game) ->
				return done new Error("Game not found for id #{gameInfo.gameObjectId}.") if !game

				game.get 'gameConfig'
					.fetch()
					.then (gameConfig) ->
						game = game.toJSON()
						game.gameConfig = gameConfig.toJSON()

						done null, game
			.fail (err) -> done err

	self.gameWorker = (gameInfo, done) ->
		self.findGame gameInfo.gameObjectId, (err, game) ->
			return $.utils.onError done, err if err

			gameInfo.game = game

			self.runGame gameInfo, (err, gameResult) ->
				return $.utils.onError done, err if err

				done null, gameResult

	self.registerWorker = (done) ->
		$.utils.amqp.rpcServer $.config.rabbitmq.queues.submission, self.worker, done

	self.worker = (msg, done) ->
		gameInfo = JSON.parse msg

		self.gameWorker gameInfo, (err, gameResult) ->
			return done JSON.stringify {errorMessage: err.message} if err

			done JSON.stringify gameResult

	return self
