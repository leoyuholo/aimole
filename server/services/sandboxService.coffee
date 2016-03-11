childProcess = require 'child_process'
path = require 'path'
events = require 'events'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'
Q = require 'q'

module.exports = ($) ->
	self = {}

	self.compile = (language, code, done) ->
		return done null if language != 'c'

		tmpId = containerName = $.utils.rng.generateId()
		sandboxrunPath = path.join $.workerDir, 'code', tmpId
		codePath = path.join sandboxrunPath, 'code.c'

		fse.outputFile codePath, code, (err) ->
			return $.utils.onError done, err if err

			compileCommand = [
				'docker'
				'run'
				'--name', tmpId
				'--rm'
				'--net', 'none'
				'--security-opt', 'apparmor:unconfined'
				'--entrypoint', 'sh'
				'-v', sandboxrunPath + ':/vol/'
				'-u', '$(id -u):$(id -g)'
				'tomlau10/sandbox-run'
				'-c', "'gcc -Wall -Wfatal-errors code.c -o code'"
			].join ' '

			childProcess.exec compileCommand, {timeout: 2000}, (err, stdout, stderr) ->
				childProcess.exec "docker rm  -f #{containerName}"
				fse.remove sandboxrunPath, () ->
					if stderr
						error = new Error('Compile Error')
						error.compileErrorMessage = stderr
						return done error

					return $.utils.onError done, err if err
					done null, {ok: true}

	class GameEntity
		constructor: (@cmd, @containerName) ->
			@process = childProcess.exec @cmd
			@dataQueue = []
			@emitter = new events()
			@timer =
				timeout: ''
				stopWatch: Date.now()

			@process.stdout.on 'data', @onData
			@process.on 'exit', @onExit
			@process.stderr.on 'data', @onError
			@process.stdin.on 'error', @onError

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
			# console.log 'receive', data
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

		pause: () =>
			@paused = true
			childProcess.exec "docker pause #{@containerName}"

		resume: () =>
			@paused = false
			childProcess.exec "docker unpause #{@containerName}"

		stopTimer: () =>
			clearTimeout @timer.timeout

			now = Date.now()
			time = now - @timer.stopWatch
			@timer.stopWatch = now

			@pause()

			return time

		startTimer: (timeLimit) =>
			@timer.stopWatch = Date.now()
			@timer.timeout = setTimeout ( () =>
				@onTimeout()
			), timeLimit

			@resume()

			return

		onTimeout: () =>
			time = @stopTimer()

			@dataQueue.push
				event: 'timeout'
				time: time

		send: (str, timeLimit) =>
			@defer = Q.defer()

			process.nextTick () =>
				return @defer.resolve {event: 'error', errorMessage: 'GameEntity error: fail to write message because process already exited.', time: 0} if @exited

				str = JSON.stringify str if _.isObject str
				str += '\n' if !/\n$/.test str

				console.log 'send', str

				@process.stdin.write str

				@startTimer timeLimit

				@dequeueData (err, data) =>
					return @defer.resolve {event: 'error', errorMessage: err.message, time: 0} if err
					@defer.resolve data

			return @defer.promise

		exit: (done) =>
			return done null if @exited && @cleaned

			if !@exited
				@process.stdin.end()

				@process.stdout.removeListener 'data', @onData
				@process.removeListener 'exit', @onExit
				@process.stderr.removeListener 'data', @onError

				@exited = true


			childProcess.exec "docker unpause #{@containerName}", (err) =>
				# ignore error
				childProcess.exec "docker rm -f #{@containerName}"

				@cleaned = true
				done null

	languageExt =
		python: '.py'
		c: '.c'
		javascript: '.js'

	kickoff = Q.async (players, verdict, verdictTimeLimit) ->
		eventCommandMap =
			data: 'player'
			exit: 'terminated'
			error: 'error'

		verdictHistory = []

		verdictCommand = '{"command": "start"}\n'
		verdictData = yield verdict.send verdictCommand, verdictTimeLimit
		verdictHistory.push
			type: 'command'
			data: verdictCommand

		loop
			if verdictData.event == 'error'
				verdictHistory.push {action: 'error', errorMessage: "Verdict error: #{verdictData.errorMessage}"}
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

				verdictHistory.push
					type: 'action'
					data: verdictAction

				if verdictAction.action == 'stop' || verdictAction.action == 'error'
					break
				else if verdictAction.action == 'next'
					playerData = yield players[verdictAction.nextPlayer].send verdictAction.writeMsg, verdictAction.timeLimit || 20000

					verdictCommand =
						player: verdictAction.nextPlayer
						command: eventCommandMap[playerData.event]
						time: playerData.time
						stdout: playerData.data

					verdictHistory.push
						type: 'command'
						data: verdictCommand

					verdictData = yield verdict.send verdictCommand, verdictTimeLimit

		return verdictHistory

	writeCodeToFile = (config, done) ->
		fse.outputFile config.codePath, config.code, done

	makeRunCmd = (sandboxConfig) ->
		[
			'docker'
			'run'
			'-i'
			'--name', sandboxConfig.containerName
			'--rm'
			'--net', 'none'
			'-v', sandboxConfig.runPath + ':/vol/'
			'-u', '$(id -u):$(id -g)'
			'tomlau10/sandbox-run'
			'-n', 1
			'-c', sandboxConfig.codeFilename
			'-CR', 'code'
		].join ' '

	self.runGame = (verdictConfig, playerConfigs, done) ->
		tmpId = $.utils.rng.generateId()
		runPath = path.join $.workerDir, tmpId

		configs = playerConfigs.concat verdictConfig

		_.each configs, (config) ->
			return done new Error("Unsupported language #{config.language}.") if !languageExt[config.language]

			config.containerName = $.utils.rng.generateId()
			config.runPath = path.join runPath, config.containerName
			config.codeFilename = "#{config.containerName}#{languageExt[config.language]}"
			config.codePath = path.join config.runPath, config.codeFilename
			config.cmd = makeRunCmd config

		async.each configs, writeCodeToFile, (err) ->
			return $.utils.onError done, err if err
			verdict = new GameEntity(verdictConfig.cmd, verdictConfig.containerName)

			players = _.map playerConfigs, (config) -> new GameEntity(config.cmd, config.containerName)
			kickoff players, verdict, 4000
				.then (verdictHistory) ->
					async.series [
						_.partial async.parallel, _.map [verdict].concat(players), 'exit'
						_.partial fse.remove, runPath
					], (err) ->
						return $.utils.onError done, err if err
						done null, verdictHistory

	return self
