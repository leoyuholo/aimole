childProcess = require 'child_process'
path = require 'path'
events = require 'events'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'
Q = require 'q'

module.exports = ($) ->
	self = {}

	class GameEntity
		constructor: (@cmd) ->
			@process = childProcess.exec @cmd
			@dataQueue = []
			@emitter = new events()
			@timer =
				timeout: ''
				stopWatch: Date.now()

			@process.stdout.on 'data', @onData
			@process.on 'exit', @onExit
			@process.stderr.on 'data', @onError

		onData: (data) =>
			time = @stopTimer()
			@enqueueData
				event: 'data'
				data: data.toString()
				time: time

		onExit: (code) =>
			time = @stopTimer()
			@enqueueData
				event: 'exit'
				time: time
				exitCode: code

			@exited = true

		onError: (errorMessage) =>
			time = @stopTimer()
			@enqueueData
				event: 'error'
				errorMessage: errorMessage
				time: time

			# don't need to exit

		enqueueData: (data) =>
			@dataQueue.push data
			@emitter.emit 'data'

		dequeueData: (done) =>
			return done null, @dataQueue.shift() if @dataQueue.length > 0

			onData = () =>
				@emitter.removeListener 'data', onData
				if @dataQueue.length > 0
					done null, @dataQueue.shift()
				else
					done new Error('GameEntity error: emit data event illegally when data queue is empty.')

			@emitter.on 'data', onData

		stopTimer: () =>
			clearTimeout @timer.timeout

			now = Date.now()
			time = now - @timer.stopWatch
			@timer.stopWatch = now

			@process.kill 'SIGSTOP'

			return time

		startTimer: (timeLimit) =>
			@timer.stopWatch = Date.now()
			@timer.timeout = setTimeout ( () =>
				@onTimeout()
			), timeLimit

			@process.kill 'SIGCONT'

			return

		onTimeout: () =>
			time = @stopTimer()

			@dataQueue.push
				event: 'timeout'
				time: time

		send: (str, timeLimit) =>
			@defer = Q.defer()

			process.nextTick () =>
				return @defer.resolve new Error('GameEntity error: fail to write message since process already exited.') if @exited

				str = JSON.stringify str if _.isObject str
				str += '\n' if !/\n$/.test str

				@process.stdin.write str

				@startTimer timeLimit

				@dequeueData (err, data) =>
					return @defer.resolve err if err
					@defer.resolve data

			return @defer.promise

		exit: () =>
			return if @exited

			@process.stdin.end()

			@process.stdout.removeListener 'data', @onData
			@process.removeListener 'exit', @onExit
			@process.stderr.removeListener 'data', @onError

			@exited = true

	self.GameEntity = GameEntity

	self.runGame = Q.async (players, verdict, verdictTimeLimit) ->
		eventCommandMap =
			data: 'player'
			exit: 'terminated'
			error: 'error'

		verdictHistory = []

		verdictData = yield verdict.send {command: 'start'}, verdictTimeLimit

		loop
			if verdictData.event == 'error'
				verdictHistory.push {action: 'error', errorMessage: "Verdict error: #{errorMessage}"}
				break
			else if verdictData.event == 'exit'
				verdictHistory.push {action: 'error', errorMessage: "Verdict exit with code [#{verdictData.exitCode}]"}
				break
			else if verdictData.event == 'data'
				try
					verdictAction = JSON.parse verdictData.data
				catch err
					verdictHistory.push {action: 'error', errorMessage: "Verdict data parse error: [#{err.message}], data: [#{verdictData.data}]"}
					break

				verdictHistory.push verdictAction

				if verdictAction.action == 'stop' || verdictAction.action == 'error'
					break
				else if verdictAction.action == 'next'
					playerData = yield players[verdictAction.nextPlayer].send verdictAction.writeMsg, verdictAction.timeLimit || 2000

					verdictCommand =
						player: verdictAction.nextPlayer
						command: eventCommandMap[playerData.event]
						time: playerData.time
						stdout: playerData.data

					verdictData = yield verdict.send verdictCommand, verdictTimeLimit

		return verdictHistory

	cleanUp = (sandboxConfig) ->
		childProcess.exec "docker rm -f #{sandboxConfig.containerName}"

	run = (playerConfigs, verdictConfig, done) ->
		verdict = new GameEntity verdictConfig.cmd

		players = _.map playerConfigs, (config) ->
			new GameEntity config.cmd

		self.runGame players, verdict, verdictConfig.timeLimit
			.then (verdictHistory) ->
				_.invoke players.concat(verdict), 'exit'
				_.each playerConfigs.concat(verdictConfig), cleanUp
				done null, verdictHistory

	sandboxrunPath = '/tmp/aimole/worker/'

	makeRunCmd = (sandboxConfig) ->
		[
			'docker'
			'run'
			'-i'
			'--name', sandboxConfig.containerName
			'--rm'
			'--net', 'none'
			'--security-opt', 'apparmor:unconfined'
			'-v', sandboxConfig.runPath + ':/vol/'
			'-u', '$(id -u):$(id -g)'
			'tomlau10/sandbox-run'
			'-n', 1
			'-c', sandboxConfig.codeFilename
			'-CR'
			sandboxConfig.executableFilename
		].join ' '

	self.run = (player1, player2, verdict, done) ->
		verdictConfig =
			runPath: path.join sandboxrunPath, 'verdict'
			codeFilename: 'verdict.js'
			executableFilename: 'verdict'
			containerName: 'verdict'
			timeLimit: 4000

		player1Config =
			runPath: path.join sandboxrunPath, 'player1'
			codeFilename: 'player1.c'
			executableFilename: 'player1'
			containerName: 'player1'

		player2Config =
			runPath: path.join sandboxrunPath, 'player2'
			codeFilename: 'player2.c'
			executableFilename: 'player2'
			containerName: 'player2'

		async.parallel [
			_.partial fse.outputFile, path.join(verdictConfig.runPath, verdictConfig.codeFilename), verdict
			_.partial fse.outputFile, path.join(player1Config.runPath, player1Config.codeFilename), player1
			_.partial fse.outputFile, path.join(player2Config.runPath, player2Config.codeFilename), player2
		], (err) ->
			return $.utils.onError done, err if err

			verdictConfig.cmd = makeRunCmd verdictConfig
			player1Config.cmd = makeRunCmd player1Config
			player2Config.cmd = makeRunCmd player2Config

			run [player1Config, player2Config], verdictConfig, done

	return self
