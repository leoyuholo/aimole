
_ = require 'lodash'
Parse = require 'parse/node'

module.exports = ($) ->

	matchSchema =
		submitBy: {
			userId: {type: String, required: true}
			displayName: {type: String, required: true}
			ranked: {type: Boolean, default: false}
		}
		gameId: {type: String, required: true}
		state: {type: String, enum: ['created', 'queued', 'running', 'evaluated'], required: true}
		players: [
			{
				type: {type: String, enum: ['ai', 'submission'], default: 'ai'} # 'me' is not a player type, replace 'me' by corresponding submission before save
				name: {type: String, default: 'Anonymous'}
				userId: {type: String}
				submissionId: {type: String}
				language: {type: String, default: 'c'}
				code: {type: String, default: ''}
			}
		]
		result: [
			{
				type: {type: String, enum: ['action', 'command', 'error'], required: true}
				errorMessage: {type: String}
				action: {
					action: {type: String, enum: ['next', 'stop', 'error'], required: true}
					display: {type: Object, required: true}
					nextPlayer: {type: Number} # when action == 'next', 0 means player1, 1 means player2, so on and so forth
					writeMsg: {type: String} # when action == 'next', can be undefined if just resuming player
					timeLimit: {type: Number, default: $.constants.time.player.defaultTimeLimit}
					goodGame: {type: Boolean, default: false} # when action == 'stop'
					score: {type: Number, default: 0} # when action == 'stop' and game.ranking == 'max'
					winner: {type: String, enum: [-1, 0, 1], default: -1} # when action == 'stop' and game.ranking == 'elo', -1 means draw
					podium: [{type: Number, default: 0}] # when action == 'stop' and game.ranking == 'podium'
				}
				command: {
					command: {type: String, enum: ['start', 'player', 'timeout', 'terminated', 'error'], required: true}
					players: [ # when command == 'start'
						{
							name: {type: String}
							score: {type: Number}
						}
					]
					player: {type: Number, required: true}
					time: {type: Number, required: true}
					stdout: {type: String} # when command == 'player'
					errorMessage: {type: String} # when command == 'error'
					exitCode: {type: Number} # when command == 'terminated'
					signalStr: {type: String} # when command == 'terminated'
				}
			}
		]

	Match = Parse.Object.extend 'Match'

	Match.schema = matchSchema

	Match.envelop = (match) ->
		slim = _.pick match, ['objectId', 'submitBy', 'gameId', 'state', 'players']
		slim.result = _.map _.filter(match.result, (r) -> r.type == 'action' || r.type == 'error'), 'action.display'
		return slim

	return Match
