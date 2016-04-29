path = require 'path'
childProcess = require 'child_process'

_ = require 'lodash'
fse = require 'fs-extra'

module.exports = ($) ->
	self = {}

	self.sendToAnalyse = (gameId, language, code, done) ->
		analysisTask =
			gameId: gameId
			language: language
			code: code

		$.utils.amqp.rpcClientJSON $.config.rabbitmq.queues.codeAnalysis, analysisTask, done

	self.analyse = (game, language, code, done) ->
		return done null, {ok: true} if !_.includes ['c', 'python', 'ruby'], language

		sandboxPath = path.join $.workerDir, 'compile', $.utils.rng.generateId()
		sandboxConfig =
			compileCommands:
				c: 'gcc -O2 -lm -o code code.c'
				python: 'python -m py_compile code.py'
				ruby: 'ruby -c code.rb'
			language: language
			commandTimeoutMs: 10000

		$.utils.objToDir sandboxPath, {"code.#{$.constants.language.extname[language]}": code}, (err) ->
			return $.utils.onError done, err if err

			$.services.sandboxService.compile sandboxPath, sandboxConfig, (err) ->
				fse.remove sandboxPath, _.noop # ignore error
				return done null, {ok: false, errorMessage: 'Compile Error', compileErrorMessage: err.compileErrorMessage} if err && /^Compile Error:/.test err.message
				return $.utils.onError done, err if err

				done null, {ok: true}

	return self
