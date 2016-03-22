
_ = require 'lodash'
async = require 'async'

module.exports = ($) ->
	self = {}

	_validate = (match, game, strict) ->
		throw new Error('Missing game id.') if !match.gameId
		throw new Error('Game id is not a string.') if !_.isString match.gameId

		throw new Error('Missing game players.') if !match.players
		throw new Error('Game players is not an array.') if !_.isArray match.players

		throw new Error('Missing game name of game.') if !game.name
		throw new Error('Game name of game is not a string.') if !_.isString match.gameId

		throw new Error('Missing number of game players of game.') if !game.players
		throw new Error('Game players of game is not a number.') if !_.isNumber game.players

		throw new Error("Number of players not match, require [#{game.players}]") if match.players.length != game.players

		throw new Error('Missing game.') if strict && !match.game
		throw new Error('Missing game verdict.') if strict && !match.game.verdict

		throw new Error('Missing game verdict code language.') if strict && !match.game.verdict.language
		throw new Error('Game verdict code language is not a string.') if strict && !_.isString match.game.verdict.language

		throw new Error('Missing game verdict code.') if strict && !match.game.verdict.code
		throw new Error('Game verdict code is not a string.') if strict && !_.isString match.game.verdict.code

		_.each match.players, (player) ->
			throw new Error('Missing player type.') if strict && !player.type
			throw new Error('Player type is not a string.') if strict && !_.isString player.type

			throw new Error('Missing player code language.') if strict && !player.language
			throw new Error('Player code language is not a string.') if strict && !_.isString player.language

			throw new Error('Missing player code.') if strict && !player.code
			throw new Error('Player code is not a string.') if strict && !_.isString player.code

			switch player.type
				when 'ai'
					throw new Error('Missing ai name.') if !player.name
					throw new Error('AI name is not a string.') if !_.isString player.name

					throw new Error("Default AI is not provided by game [#{game.name}].") if !game.ai || !game.ai.length
					ais = _.map game.ai, 'name'
					throw new Error("Specified ai [#{player.name}] is not provided by game [#{game.name}].") if !_.includes ais, player.name
				when 'submission'
					throw new Error('Missing player user id.') if !player.userId
					throw new Error('Player user id is not a string.') if !_.isString player.userId

					throw new Error('Missing player submission id.') if !player.submissionId
					throw new Error('Player submission id is not a string.') if !_.isString player.submissionId

					throw new Error('Missing player name.') if strict && !player.name
					throw new Error('Player name.') if strict && !_.isString player.name
				when 'me'
					throw new Error("Invalid player type 'me'.") if strict
				else
					throw new Error("Invalid player type '#{player.type}'.")

		return

	self.validate = (match, done) ->
		return done new Error('Missing game id.') if !match.gameId

		$.stores.gameStore.findById match.gameId, (err, game) ->
			return $.utils.onError done, err if err
			return done new Error("Game not found for id [#{match.gameId}].") if !game

			try
				_validate match, game, false
			catch err
				return $.utils.onError done, err

			done null

	self.findMatchWithCode = (matchId, done) ->
		$.stores.matchStore.findById matchId, (err, match) ->
			return $.utils.onError done, err if err
			return done new Error("Match not found for id: [#{matchId}].") if !match

			$.stores.gameStore.findById match.gameId, (err, game) ->
				return $.utils.onError done, err if err
				return done new Error("Game not found for id [#{match.gameId}].") if !game

				try
					_validate match, game, false
				catch err
					return $.utils.onError done, err

				async.map match.players, ( (player, done) ->
					if player.type == 'ai'
						done null, _.cloneDeep _.find game.ai, {name: player.name}
					else if player.type == 'submission'
						$.stores.submissionStore.findById player.submissionId, (err, submission) ->
							return done err if err
							return done new Error("Submission not found for id: [#{player.submissionId}].") if !submission

							newPlayer =
								type: player.type
								name: submission.displayName
								userId: player.userId
								submissionId: player.submissionId
								language: submission.language
								code: submission.code

							done null, newPlayer
					else
						done new Error("Invalid player type '#{player.type}'.")
				), (err, players) ->
					return $.utils.onError done, err if err

					match.game = game
					match.players = players

					try
						_validate match, game, true
					catch err
						return $.utils.onError done, err

					done null, match

	self.create = (newMatch, done) ->
		async.series [
			_.partial self.validate, newMatch
			_.partial async.waterfall, [
				_.partial $.stores.matchStore.findByGameIdAndPlayers, newMatch.gameId, newMatch.players
				(match, done) ->
					if match
						done null, match
					else
						$.stores.matchStore.create newMatch, done
			]
		], (err, [__, match]) ->
			return $.utils.onError done, err if err
			done null, match

	self.play = (matchId, done) ->
		return done new Error('Missing match id.') if !matchId
		$.utils.amqp.rpcClientJSON $.config.rabbitmq.queues.playMatch, {matchId: matchId}, (err, result) ->
			return $.utils.onError done, err if err
			return $.utils.onError done, new Error('No results received from rpc.') if !result
			return $.utils.onError done, new Error("Error: #{result.errorMessage}") if !result.ok
			done null, result.result

	return self
