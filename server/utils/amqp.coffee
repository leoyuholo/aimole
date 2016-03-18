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

	self.rpcServerJSON = (queueName, workerFunc, done) ->
		func = (msg, done) ->
			try
				msgObj = JSON.parse msg
			catch err
				return done {ok: false, errorMessage: err.message}
			workerFunc msgObj, (replyObj) -> done JSON.stringify replyObj
		self.rpcServer queueName, func, done

	self.rpcClientJSON = (queueName, msgObj, done) ->
		msgContent = JSON.stringify msgObj
		self.rpcClient queueName, msgContent, (err, replyContent) ->
			return done err if err
			try
				replyObj = JSON.parse replyContent
			catch err
				return done err
			done null, replyObj

	self.rpcServer = (queueName, workerFunc, done) ->
		self.conn.createChannel (err, ch) ->
			return done err if err

			ch.assertQueue queueName, {durable: false}
			ch.prefetch 1

			ch.consume queueName, (msg) ->
				# console.log 'rpcServer msg', msg.content.toString()
				workerFunc msg.content.toString(), (reply) ->
					# console.log 'rpcServer reply', reply
					ch.sendToQueue msg.properties.replyTo, new Buffer(reply.toString()), {correlationId: msg.properties.correlationId}

					ch.ack msg

			done null

	self.rpcClient = (queueName, msgContent, done) ->
		# console.log 'rpcClient msg', msgContent
		self.conn.createChannel (err, ch) ->
			return done err if err

			ch.assertQueue '', {exclusive: true}, (err, q) ->
				correlationId = uuid.v4()
				consumerTag = uuid.v4()

				ch.consume q.queue, (msg) ->
					if msg.properties.correlationId == correlationId
						ch.cancel consumerTag, (err) ->
							# console.log 'rpcClient reply', msg.content.toString()
							done err, msg.content.toString()
				, {noAck: true, consumerTag: consumerTag}

				ch.sendToQueue queueName, new Buffer(msgContent.toString()), {correlationId: correlationId, replyTo: q.queue}

	return self
