_ = require 'lodash'
uuid = require 'node-uuid'
amqp = require 'amqplib/callback_api'

module.exports = ($) ->
	self = {}

	self.conn = {}

	self.connect = (url, done) ->
		amqp.connect url, (err, conn) ->
			return done err if err

			self.conn = conn

			done null

	self.rpcServer = (queueName, workerFunc, done) ->
		self.conn.createChannel (err, ch) ->
			return done err if err

			ch.assertQueue queueName, {durable: false}
			ch.prefetch 1

			ch.consume queueName, (msg) ->
				workerFunc msg.content.toString(), (reply) ->
					ch.sendToQueue msg.properties.replyTo, new Buffer(reply.toString()), {correlationId: msg.properties.correlationId}

					ch.ack msg

			done null

	self.rpcClient = (queueName, msgContent, done) ->
		self.conn.createChannel (err, ch) ->
			return done err if err

			ch.assertQueue '', {exclusive: true}, (err, q) ->
				correlationId = uuid.v4()
				consumerTag = uuid.v4()

				ch.consume q.queue, (msg) ->
					if msg.properties.correlationId == correlationId
						ch.cancel consumerTag, (err) ->
							done err, msg.content.toString()
				, {noAck: true, consumerTag: consumerTag}

				ch.sendToQueue queueName, new Buffer(msgContent.toString()), {correlationId: correlationId, replyTo: q.queue}

	return self
