async = require 'async'
Parse = require 'parse/node'

module.exports = ($) ->
	self = {}

	parseSetup = (done) ->
		return done null if $.Parse
		Parse.initialize $.config.Parse.appId, '', $.config.Parse.masterKey
		Parse.serverURL = $.config.Parse.serverURL
		Parse.Cloud.useMasterKey()

		$.Parse = Parse

		done null

	setupRabbitMQ = (done) ->
		$.utils.amqp.connect "amqp://#{$.config.rabbitmq.host}:#{$.config.rabbitmq.port}", done

	self.run = (done) ->
		async.series [
			parseSetup
			setupRabbitMQ
		], done

	return self
