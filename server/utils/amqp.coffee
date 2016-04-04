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
			self.conn.createChannel (err, ch) ->
				return done err if err
				self.ch = ch
				done null, self.ch

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

	self.publishJSON = (queueName, key, msgObj, done) ->
		msgContent = JSON.stringify msgObj
		self.publish queueName, key, msgContent, done

	self.subscribeJSON = (queueName, key, workerFunc, done) ->
		func = (msg) ->
			try
				msgObj = JSON.parse msg
			catch err
				# console.log 'amqp subscribeJSON JSON.parse error:', err
				return
			workerFunc msgObj
		self.subscribe queueName, key, func, done

	self.publish = (queueName, key, msgContent, done) ->
		# console.log 'publish msg', msgContent.toString()
		self.ch.assertExchange queueName, 'topic', {durable: false}
		self.ch.publish queueName, key, new Buffer(msgContent.toString())
		done null

	self.subscribe = (queueName, key, workerFunc, done) ->
		consumerTag = uuid.v4()
		self.ch.assertExchange queueName, 'topic', {durable: false}
		self.ch.assertQueue '', {exclusive: true}, (err, q) ->
			return done err if err
			self.ch.bindQueue q.queue, queueName, key
			self.ch.consume q.queue, (msg) ->
				# console.log 'subscribe msg', msg.content.toString()
				workerFunc msg.content.toString()
			, {noAck: true, consumerTag: consumerTag}
			done null, consumerTag

	self.unsubscribe = (consumerTag, done) ->
		self.ch.cancel consumerTag, done

	self.rpcServer = (queueName, workerFunc, done) ->
		self.ch.assertQueue queueName, {durable: false}
		self.ch.prefetch 1

		self.ch.consume queueName, (msg) ->
			# console.log 'rpcServer msg', msg.content.toString()
			workerFunc msg.content.toString(), (reply) ->
				# console.log 'rpcServer reply', reply
				self.ch.sendToQueue msg.properties.replyTo, new Buffer(reply.toString()), {correlationId: msg.properties.correlationId}

				self.ch.ack msg

		done null

	self.rpcClient = (queueName, msgContent, done) ->
		# console.log 'rpcClient msg', msgContent
		self.ch.assertQueue '', {exclusive: true}, (err, q) ->
			correlationId = uuid.v4()
			consumerTag = uuid.v4()

			self.ch.consume q.queue, (msg) ->
				if msg.properties.correlationId == correlationId
					self.ch.cancel consumerTag, (err) ->
						# console.log 'rpcClient reply', msg.content.toString()
						done err, msg.content.toString()
			, {noAck: true, consumerTag: consumerTag}

			self.ch.sendToQueue queueName, new Buffer(msgContent.toString()), {correlationId: correlationId, replyTo: q.queue}

	return self
