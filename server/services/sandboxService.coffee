childProcess = require 'child_process'
path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	names = ['verdict', 'player1', 'player2']

	killAll = () ->
		console.log 'killing all'
		names.forEach (name) ->
			childProcess.exec "docker rm -f #{name}"

	initProcess = (process, label, onData, onTimeout, onExit, onError) ->
		console.log 'init', label
		exited = false

		timer =
			timeout: ''
			timeLimit: 4000
			stopWatch: Date.now()

		process.stdout.on 'data', (data) ->
			clearTimeout timer.timeout
			console.log 'receive', label, 'data', data
			onData data.toString(), (Date.now() - timer.stopWatch)

		process.on 'exit', () ->
			console.log 'exit', label
			onExit()

		process.stderr.on 'data', (err) ->
			console.log 'error', err
			onError new Error(err)

		write = (str) ->
			if !exited
				str += '\n' if !/\n$/.test str
				console.log 'write:', label, 'data', "[#{str}]"
				process.stdin.write str
				timer.stopWatch = Date.now()
				timer.timeout = setTimeout ( () ->
					onTimeout Date.now() - timer.stopWatch, label
				), timer.timeLimit

		writeJson = (obj) ->
			write JSON.stringify obj if !exited

		exit = () ->
			exited = true

		return {
			write: write
			writeJson: writeJson
			exit: exit
		}

	initPlayer = (process, playerLabel, verdict) ->

		onPlayerData = (data, timeElapsed) ->
			console.log arguments
			# playerData:
			# 	command: 'player'
			# 	player: [0, 1]
			# 	time: 1234
			# 	stdout: 'string'
			console.log 'onPlayerData', data, "timeElapsed[#{timeElapsed}]"
			playerData =
				command: 'player'
				player: playerLabel
				time: timeElapsed
				stdout: data

			verdict.writeJson playerData

		onPlayerTimeout = (timeElapsed) ->
			playerData =
				command: 'timeout'
				player: playerLabel
				time: timeElapsed

			verdict.writeJson playerData

		onPlayerExit = () ->
			# playerData:
			# 	command: 'terminated'
			# 	player: [0, 1]
			playerData =
				command: 'terminated'
				player: playerLabel

			verdict.writeJson playerData

		onPlayerError = (err) ->
			# playerData:
			# 	command: 'error'
			# 	player: [0, 1]
			# 	errorMessage: 'string'
			playerData =
				command: 'error'
				player: playerLabel
				errorMessage: err.message

			verdict.writeJson playerData

		initProcess process, playerLabel, onPlayerData, onPlayerTimeout, onPlayerExit, onPlayerError

	initVerdict = (process, players, done) ->
		# TODO: use promise
		verdictHistory = []
		exited = false

		exit = (err) ->
			_.invoke players, 'exit'
			verdict.exit()
			if !exited
				exited = true
				killAll()
				return done err if err
				done null, verdictHistory

		onVerdictData = (data) ->
			# verdictCommand:
			# 	command: ['start', 'player', 'terminated', 'error']
			# 	player: [0, 1]
			# 	timeMs: 1234
			# 	stdout: 'string'
			# 	errorMessage: 'string'
			# verdictAction:
			# 	action: ['stop', 'next', 'error']
			# 	nextPlayer: [0, 1]
			# 	score: [100, 0]
			# 	writeMsg: 'string'
			# 	errorMessage: 'string'
			verdictAction = JSON.parse data
			verdictHistory.push verdictAction
			switch verdictAction.action
				when 'stop'
					# TODO: kill all process
					exit()
				when 'next'
					players[verdictAction.nextPlayer].write "#{verdictAction.writeMsg}"
				when 'error'
					exit new Error(verdictAction.errorMessage)

		onVerdictTimeout = () ->
			exit new Error('Verdict timeout.')

		onVerdictError = (err) ->
			exit new Error('Verdict error.')

		onVerdictExit = () ->
			exit()

		verdict = initProcess process, 'v', onVerdictData, onVerdictTimeout, onVerdictExit, onVerdictError
		players = _.map players, (player, index) ->
			initPlayer player, index, verdict

		return verdict

	runGame = (verdict, players, done) ->
		verdict = initVerdict verdict, players, done
		verdict.writeJson {command: 'start'}

	sandboxrunPath = '/tmp/aimole/worker/'

	makeRunCmd = (sandboxrunPath, sandboxConfig) ->
		[
			'docker'
			'run'
			'-i'
			'--name', sandboxConfig.containerName
			'--rm'
			'--net', 'none'
			'--security-opt', 'apparmor:unconfined'
			'-v', sandboxrunPath + ':/vol/'
			'-u', '$(id -u):$(id -g)'
			'tomlau10/sandbox-run'
			'-n', 1
			'-c', sandboxConfig.codeFilename
			'-CR'
			sandboxConfig.executableFilename
		].join ' '

	makeVerdictCmd = (sandboxrunPath, sandboxConfig) ->
		# [
		# 	'node'
		# 	path.join sandboxrunPath, sandboxConfig.codeFilename
		# ].join ' '
		[
			'docker'
			'run'
			'-i'
			'--name', sandboxConfig.containerName
			'--rm'
			'--net', 'none'
			'--security-opt', 'apparmor:unconfined'
			'-v', sandboxrunPath + ':/vol/'
			'-u', '$(id -u):$(id -g)'
			'tomlau10/sandbox-run'
			'-n', 1
			'-c', sandboxConfig.codeFilename
			'-CR'
			sandboxConfig.executableFilename
		].join ' '

	runCode = (code, sandboxrunPath, sandboxConfig, done) ->
		fse.outputFile path.join(sandboxrunPath, sandboxConfig.codeFilename), code, (err) ->
			return $.utils.onError done, err if err

			console.log makeRunCmd sandboxrunPath, sandboxConfig

			done null, childProcess.exec makeRunCmd sandboxrunPath, sandboxConfig

	runVerdict = (code, sandboxrunPath, sandboxConfig, done) ->
		fse.outputFile path.join(sandboxrunPath, sandboxConfig.codeFilename), code, (err) ->
			return $.utils.onError done, err if err

			console.log makeVerdictCmd sandboxrunPath, sandboxConfig

			done null, childProcess.exec makeVerdictCmd sandboxrunPath, sandboxConfig

	self.run = (player1, player2, verdict, done) ->
		async.parallel [
			_.partial runVerdict, verdict, path.join(sandboxrunPath, 'verdict'), {codeFilename: 'verdict.py', executableFilename: 'verdict', containerName: 'verdict'}
			# _.partial runVerdict, verdict, path.join(sandboxrunPath, 'verdict'), {codeFilename: 'verdict.js', executableFilename: 'verdict', containerName: 'verdict'}
			_.partial runCode, player1, path.join(sandboxrunPath, 'player1'), {codeFilename: 'player1.c', executableFilename: 'player1', containerName: 'player1'}
			_.partial runCode, player2, path.join(sandboxrunPath, 'player2'), {codeFilename: 'player2.c', executableFilename: 'player2', containerName: 'player2'}
		], (err, [verdict, player1, player2]) ->
			return $.utils.onError done, err if err

			runGame verdict, [player1, player2], done

	return self
