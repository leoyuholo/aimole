
_ = require 'lodash'
Parse = require 'parse/node'

module.exports = ($) ->
	languages = $.constants.language.names

	# ranking:
	# 'max': replace score if new score > current score
	# 'elo': update score by elo rating system
	# 'podium': add score to players' current score directly, e.g. [30, 10, 0, -10, -30] means add 30 to player1, ..., unchange for player3, ..., minus 30 to player5
	gameSchema =
		githubUrl: {type: String, required: true}
		name: {type: String, required: true}
		description: {type: String, default: ''}
		author: {type: String, default: ''}
		version: {type: String, default: '0.0.0'}
		viewUrl: {type: String, default: ''}
		bgUrl: {type: String, default: ''}
		players: {type: Number, default: 1}
		ranking: {
			scheme: {type: String, enum: ['max', 'elo', 'podium'], required: true} # 'max' for single player, 'elo' for two players, 'podium' for mutiple players
			baseScore: {type: Number, default: 0}
		}
		ai: [
			type: {type: String, default: 'ai'}
			name: {type: String, required: true}
			language: {type: String, enum: languages, default: 'c'}
			code: {type: String, required: true}
			file: {type: String, default: ''}
		]
		codetpl: {
			c: {type: 'String', default: ''}
		}
		verdict:
			language: {type: String, enum: languages, default: 'c'}
			code: {type: String, required: true}
			file: {type: String, default: ''}
			timeLimit: {type: Number, default: $.constants.time.verdict.defaultTimeLimit}

	Game = Parse.Object.extend 'Game'

	Game.schema = gameSchema

	Game.envelop = (game) ->
		slim = _.pick game, ['objectId', 'name', 'description', 'author', 'version', 'viewUrl', 'bgUrl', 'players', 'ranking', 'codeTpl']
		slim.ai = _.map game.ai, (ai) -> _.pick ai, ['type', 'name']
		return slim

	return Game
