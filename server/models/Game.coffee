
_ = require 'lodash'
mongoose = require 'mongoose'

module.exports = ($) ->

	game =
		gid: {type: String, required: true}
		name: {type: String, required: true}
		description: {type: String}

	gameSchema = new mongoose.Schema(game)

	gameSchema.index {gid: 1}, {unique: true}

	attrKeys = _.keys game
	gameSchema.static 'envelop', (doc) ->
		_.pick doc, attrKeys

	return mongoose.model 'Game', gameSchema
