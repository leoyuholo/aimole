
module.exports = ($) ->
	self = {}

	self.registerAnalysisWorker = (done) ->
		$.utils.amqp.rpcServerJSON $.config.rabbitmq.queues.codeAnalysis, self.analysisWorker, done

	self.analysisWorker = (msg, done) ->
		gameId = msg.gameId
		language = msg.language
		code = msg.code
		$.stores.gameStore.findById gameId, (err, game) ->
			return done {ok: false, errorMessage: err.message} if err
			return done {ok: false, errorMessage: "Game not found for id: [#{gameId}]."} if !game

			$.services.codeService.analyse game, language, code, (err, result) ->
				return done {ok: false, errorMessage: err.message} if err
				done result

	self.registerPlayMatchWorker = (done) ->
		$.utils.amqp.rpcServerJSON $.config.rabbitmq.queues.playMatch, self.playMatchWorker, done

	self.playMatchWorker = (msg, done) ->
		matchId = msg.matchId
		$.services.matchService.findMatchWithCode matchId, (err, match) ->
			return done {ok: false, errorMessage: err.message} if err

			$.services.gameService.play match, {}, (err, result) ->
				return done {ok: false, errorMessage: err.message} if err

				done {ok: true, result: result}

	return self
