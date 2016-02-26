
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	checkGameInfo = (gameInfo, done) ->
		return done new Error('Missing game id.') if !gameInfo.gameObjectId
		return done new Error('Missing game players.') if !gameInfo.players

		(new $.Parse.Query($.models.Game)).get gameInfo.gameObjectId
			.then (game) ->
				return done new Error("Game not found for id #{gameInfo.gameObjectId}.") if !game
				# if _.isObject game.players
				# 	return done new Error("Too less players, require at least #{game.gameConfig.players.min}.") if gameInfo.players.length < game.gameConfig.players.min
				# 	return done new Error("Too much players, require at most #{game.gameConfig.players.min}.") if gameInfo.players.length > game.gameConfig.players.max
				# else
				# 	return done new Error("Number of players not match, require #{game.gameConfig.players}") if gameInfo.players.length != game.gameConfig.players
				return done new Error("Number of players not match, require #{game.players}") if gameInfo.players.length != game.get 'players'

				ais = _.map game.get('ai'), 'name'
				for player in gameInfo.players
					return done new Error("Specified ai [#{player.name}] does not exist.") if player.type == 'ai' && !_.includes ais, player.name
				done null
			.fail (err) -> done err

	self.run = (gameInfo, done) ->
		submissionId = $.utils.rng.generateId()
		try
			gameInfo.players = _.map gameInfo.players, (player) ->
				return {type: 'ai', name: player.name} if player.type == 'ai'
				return {type: 'human', human: {playerId: player.human.playerId, submissionId: player.human.submissionId}} if player.type == 'human'
				throw new Error('Unknow player type. Player type must be one of [ai], [human]')
		catch err
			# TODO: catch object traversal error
			return done err

		checkGameInfo gameInfo, (err) ->
			return $.utils.onError done, err if err

			console.log 'gameInfo', gameInfo

			$.utils.amqp.rpcClient $.config.rabbitmq.queues.submission, JSON.stringify(gameInfo), (err, gameResult) ->
				return $.utils.onError done, err if err

				done null, gameResult

	return self
