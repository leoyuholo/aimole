
async = require 'async'
mongoose = require 'mongoose'

module.exports = ($) ->
	self = {}

	setupMongoose = (done) ->
		mongoose.connect "mongodb://#{$.config.mongodb.host}:#{$.config.mongodb.port}/#{$.config.mongodb.db}", done

	self.run = (done) ->
		setupMongoose done

	return self
