path = require 'path'

_ = require 'lodash'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	gameCache = {}

	self.runGame = (gameInfo, done) ->
		console.log 'runGame', gameInfo
		done null, [
			[[0, 0, 0], [0, 0, 0], [0, 0, 0]],
			[[1, 0, 0], [0, 0, 0], [0, 0, 0]],
			[[1, 2, 0], [0, 0, 0], [0, 0, 0]],
			[[1, 2, 0], [0, 1, 0], [0, 0, 0]],
			[[1, 2, 0], [0, 1, 0], [0, 0, 2]],
			[[1, 2, 0], [0, 1, 0], [1, 0, 2]],
			[[1, 2, 0], [2, 1, 0], [1, 0, 2]],
			[[1, 2, 0], [2, 1, 0], [1, 1, 2]],
			[[1, 2, 0], [2, 1, 2], [1, 1, 2]],
			[[1, 2, 1], [2, 1, 2], [1, 1, 2]]
		]

	self.findGame = (gameObjectId, done) ->
		(new $.Parse.Query($.models.Game)).get gameObjectId
			.then (game) ->
				return done new Error("Game not found for id #{gameInfo.gameObjectId}.") if !game

				# TODO: fetch gameConfig for game

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
