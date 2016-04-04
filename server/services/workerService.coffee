
_ = require 'lodash'
async = require 'async'

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

			onData = (record, index) ->
				$.stores.matchStore.addResult matchId, record, _.noop
				$.utils.amqp.publishJSON $.config.rabbitmq.queues.matchStream, matchId, {event: 'data', record: record, index: index}, _.noop

			async.waterfall [
				(done) -> $.stores.matchStore.setState matchId, 'running', (err) -> done err
				_.partial $.services.gameService.play, match, {onData: onData, onError: onData}
				_.partial $.stores.matchStore.finalizeResult, matchId
			], (err, match) ->
				return done {ok: false, errorMessage: err.message} if err

				match = $.models.Match.envelop match
				$.utils.amqp.publishJSON $.config.rabbitmq.queues.matchStream, matchId, {event: 'end'}, _.noop
				done {ok: true, match: match}

	return self
