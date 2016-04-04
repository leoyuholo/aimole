path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'
Q = require 'q'

module.exports = ($) ->
	self = {}

	eventCommandMap =
		data: 'player'
		exit: 'terminated'
		error: 'error'
		timeout: 'timeout'

	class GameHistory
		constructor: (@listeners) ->
			@history = []

		logCommand: (command) =>
			record =
				type: 'command'
				command: command
			index = @history.push record
			@listeners.onData record, index - 1 if @listeners.onData

		logAction: (action) =>
			record =
				type: 'action'
				action: action
			index = @history.push record
			@listeners.onData record, index - 1 if @listeners.onData

		logError: (error) =>
			record =
				type: 'error'
				errorMessage: error.message
				action:
					display:
						errorMessage: error.message
			index = @history.push record
			@listeners.onError record, index - 1 if @listeners.onError

		getHistory: () =>
			@history

	_kickoff = Q.async (match, verdictEntity, playerEntities, listeners) ->
		verdictTimeLimit = match.game.verdict.timeLimit || $.constants.time.verdict.defaultTimeLimit
		defaultPlayerTimeLimit = $.constants.time.player.defaultTimeLimit

		verdictCommand =
			command: 'start'
			players: _.map match.players, (p) -> {name: p.name}
		gameHistory = new GameHistory(listeners)
		gameHistory.logCommand verdictCommand

		verdictData = yield verdictEntity.send verdictCommand, verdictTimeLimit
		loop
			if verdictData.event == 'error'
				gameHistory.logError new Error("Verdict error: #{verdictData.errorMessage}")
				break
			else if verdictData.event == 'exit'
				gameHistory.logError new Error("Verdict exit with code [#{verdictData.exitCode}]")
				break
			else if verdictData.event == 'timeout'
				gameHistory.logError new Error("Verdict timeout with time [#{verdictData.time}]")
				break
			else if verdictData.event == 'data'
				try
					verdictAction = JSON.parse verdictData.data
				catch err
					gameHistory.logError new Error("Verdict data parse error: [#{err.message}], data: [#{verdictData.data}]")
					break

				if verdictAction.action == 'stop' || verdictAction.action == 'error'
					gameHistory.logAction verdictAction
					break
				else if verdictAction.action == 'next'
					gameHistory.logAction verdictAction
					playerData = yield playerEntities[verdictAction.nextPlayer].send verdictAction.writeMsg, verdictAction.timeLimit || defaultPlayerTimeLimit

					verdictCommand =
						player: verdictAction.nextPlayer
						command: eventCommandMap[playerData.event]
						time: playerData.time
					switch verdictCommand.command
						when 'player'
							verdictCommand.stdout = playerData.data
						when 'error'
							verdictCommand.errorMessage = playerData.errorMessage
						when 'terminated'
							verdictCommand.exitCode = playerData.exitCode
							verdictCommand.signalStr = playerData.signalStr

					gameHistory.logCommand verdictCommand

					verdictData = yield verdictEntity.send verdictCommand, verdictTimeLimit
				else
					gameHistory.logError new Error("Unkown verdict action #{verdictAction.action}, data: [#{verdictData.data}].")
					break

		return gameHistory.getHistory()

	kickoff = (match, verdictEntity, playerEntities, listeners, done) ->
		_kickoff match, verdictEntity, playerEntities, listeners
			.then (result) -> done null, result
			.catch (err) -> done err

	self.play = (match, listeners, done) ->
		game = match.game
		verdict = game.verdict
		players = match.players

		onError = (err) ->
			listeners.onError err if _.isFunction listeners.onError
			$.utils.onError done, err

		gameDir = path.join $.workerDir, $.utils.rng.generateId()

		verdict.sandboxPath = path.join gameDir, 'verdict'
		verdict.filename = "code.#{$.constants.languageExtname[verdict.language]}"
		dirObj = {}
		dirObj.verdict = {}
		dirObj.verdict[verdict.filename] = verdict.code

		dirObj.players = {}
		_.each players, (player, index) ->
			playerDirname = "player#{index}"

			player.sandboxPath = path.join gameDir, 'players', playerDirname
			player.filename = "code.#{$.constants.languageExtname[player.language]}"

			playerObj = {}
			playerObj[player.filename] = player.code
			dirObj.players[playerDirname] = playerObj

		$.utils.objToDir gameDir, dirObj, (err) ->
			return onError err if err

			makeEntityFuncs = [_.partial $.services.gameEntityService.makeVerdictEntity, verdict, game]
			makeEntityFuncs = makeEntityFuncs.concat _.map players, (p) -> _.partial $.services.gameEntityService.makePlayerEntity, p, game

			async.parallel makeEntityFuncs, (err, [verdictEntity, playerEntities...]) ->
				return onError err if err
				kickoff match, verdictEntity, playerEntities, listeners, (err, result) ->
					return onError err if err
					# TODO: update elo score if applicable
					async.series [
						_.partial async.parallel, _.map [verdictEntity].concat(playerEntities), 'exit'
						# _.partial fse.remove, gameDir
					], (err) ->
						return $.utils.onError done, err if err
						done null, result

	return self
