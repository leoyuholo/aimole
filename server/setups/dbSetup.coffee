async = require 'async'
Parse = require 'parse/node'

module.exports = ($) ->
	self = {}

	setupRabbitMQ = (done) ->
		$.utils.amqp.connect "amqp://#{$.config.rabbitmq.host}:#{$.config.rabbitmq.port}", done

	setupParse = (done) ->
		Parse.initialize $.config.Parse.appId, '', $.config.Parse.masterKey
		Parse.serverURL = $.config.Parse.serverURL
		Parse.Cloud.useMasterKey()

		$.Parse = Parse

		done null

	self.run = (done) ->
		async.series [
			setupRabbitMQ
			setupParse
		], done

	return self
