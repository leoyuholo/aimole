
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.registerWorker = (done) ->
		$.utils.amqp.rpcServer $.config.rabbitmq.queues.submission, self.worker, done

	self.worker = (msg, done) ->
		$.logger.info msg

		done JSON.stringify [
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

	return self
