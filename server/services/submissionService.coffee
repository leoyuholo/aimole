
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.run = (gameInfo, done) ->
		$.utils.amqp.rpcClient $.config.rabbitmq.queues.submission, JSON.stringify(gameInfo), (err, gameResult) ->
			return $.utils.onError done, err if err

			done null, gameResult

	return self
