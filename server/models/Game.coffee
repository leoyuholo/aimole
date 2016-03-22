
_ = require 'lodash'
Parse = require 'parse/node'

module.exports = ($) ->
	# languages = ['c', 'javascript', 'python', 'ruby']

	# gameSchema =
	# 	githubUrl: {type: String, required: true}
	# 	name: {type: String, required: true}
	# 	description: {type: String, default: ''}
	# 	author: {type: String, default: ''}
	# 	version: {type: String, default: '0.0.0'}
	# 	viewUrl: {type: String, default: ''}
	# 	bgUrl: {type: String, default: ''}
	# 	players: {type: Number, default: 1}
	# 	ai: [
	# 		type: {type: String, default: 'ai'}
	# 		name: {type: String, default: 'Anonymous AI'}
	# 		language: {type: String, enum: languages, default: 'c'}
	# 		code: {type: String, default: 'Missing ai code'}
	# 		file: {type: String, default: ''}
	# 	]
	# 	verdict:
	# 		language: {type: String, enum: languages, default: 'c'}
	# 		code: {type: String, default: 'Missing verdict code'}
	# 		file: {type: String, default: ''}
	# 		timeLimit: {type: Number, default: 2000}
	Game = Parse.Object.extend 'Game'

	# Game.GameSchema =
	# 	githubUrl: 'str'
	# 	name: 'str'
	# 	description: 'str'
	# 	author: 'str'
	# 	version: 'str'
	# 	viewUrl: 'str'
	# 	bgUrl: 'str'
	# 	players: []
	# 	ai: []
	# 	verdict: {}

	Game.envelop = (game) ->
		slim = _.pick game, ['objectId', 'name', 'description', 'author', 'version', 'viewUrl', 'bgUrl', 'players']
		slim.ai = _.map game.ai, (ai) -> _.pick ai, ['type', 'name']
		return slim

	return Game
