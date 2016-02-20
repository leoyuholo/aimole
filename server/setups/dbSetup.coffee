amqp = require 'amqplib/callback_api'
Parse = require 'parse'

module.exports = ($) ->
	self = {}

	setupRabbitMQ = (done) ->
		amqp.connect "amqp://#{$.config.rabbitmq.host}:#{$.config.rabbitmq.port}", (err, conn) ->
			return $.utils.onError done, err if err

			conn.createChannel (err, ch) ->
				return $.utils.onError done, err if err

				$.amqp = ch
				$.amqp.prefetch 1

				done null

	setupParse = (done) ->
		Parse.initialize $.config.Parse.appId, '', $.config.Parse.masterKey
		Parse.serverURL = $.config.Parse.serverURL

		$.Parse = Parse

		done null

	self.run = (done) ->
		async.series [
			setupRabbitMQ
			setupParse
		], done

	return self
