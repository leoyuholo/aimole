childProcess = require 'child_process'
events = require 'events'

_ = require 'lodash'
Q = require 'q'

module.exports = ($) ->
	self = {}

	class GameEntity
		constructor: (@process, @containerName) ->
			@dataQueue = []
			@emitter = new events()
			@timer =
				timeout: ''
				stopWatch: Date.now()
			@paused = false
			@exited = false
			@cleaned = false

			@process.stdout.on 'data', @onData
			@process.on 'exit', @onExit
			@process.stderr.on 'data', @onError
			@process.stdin.on 'error', @onError

		onData: (data) =>
			time = @stopTimer()
			@enqueueData
				event: 'data'
				time: time
				data: data.toString()

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
				time: time
				errorMessage: errorMessage

			# don't need to exit

		onTimeout: () =>
			time = @stopTimer()
			@enqueueData
				event: 'timeout'
				time: time

		enqueueData: (data) =>
			# console.log 'receive', data
			@dataQueue.push data
			@emitter.emit 'data'

		dequeueData: (done) =>
			return done null, @dataQueue.shift() if @dataQueue.length > 0

			onData = () =>
				@emitter.removeListener 'data', onData
				return done null, @dataQueue.shift() if @dataQueue.length > 0
				done new Error('GameEntity error: emit data event illegally when data queue is empty.')

			@emitter.on 'data', onData

		pause: () =>
			return if @paused
			@paused = true
			childProcess.exec "docker pause #{@containerName}"

		resume: () =>
			return if !@paused
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
			@timer.timeout = setTimeout ( () => @onTimeout()), timeLimit
			@resume()
			return

		send: (str, timeLimit) =>
			defer = Q.defer()

			process.nextTick () =>
				return defer.resolve {event: 'error', errorMessage: 'GameEntity error: fail to write message because process already exited.', time: 0} if @exited

				str = JSON.stringify str if _.isObject str
				str += '\n' if !/\n$/.test str

				# console.log 'send', str

				@process.stdin.write str
				@startTimer timeLimit
				@dequeueData (err, data) =>
					return defer.resolve {event: 'error', errorMessage: err.message, time: 0} if err
					defer.resolve data

			return defer.promise

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

	makeEntity = (entity, done) ->
		containerName = $.utils.rng.generateId()
		sandboxConfig =
			compileCommands:
				c: 'gcc -O2 -lm -o code code.c'
				javascript: ''
				python: ''
				ruby: ''
			executableFilename: 'code'
			language: entity.language
			codeFilename: entity.filename
			memoryLimitMB: 128
			commandTimeoutMs: 10000

		$.services.sandboxService.compileAndRun entity.sandboxPath, sandboxConfig, containerName, (err, process) ->
			return $.utils.onError done, err if err
			done null, new GameEntity(process, containerName)

	self.makeVerdictEntity = (verdict, game, done) ->
		makeEntity verdict, done

	self.makePlayerEntity = (player, game, done) ->
		makeEntity player, done

	return self
