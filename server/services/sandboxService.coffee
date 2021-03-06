childProcess = require 'child_process'

_ = require 'lodash'

module.exports = ($) ->
	self = {}

	makeCompileCmd = (sandboxPath, sandboxConfig, containerName) ->
		compileCommand = sandboxConfig.compileCommands[sandboxConfig.language]
		return compileCommand if !compileCommand
		[
			'docker'
			'run'
			'--name', containerName
			'--net', 'none'
			'--entrypoint', 'sh'
			'-v', sandboxPath + ':/vol/'
			'-u', '$(id -u):$(id -g)'
			'tomlau10/sandbox-run'
			'-c', "'#{compileCommand}'"
		].join ' '

	makeRunCmd = (sandboxPath, sandboxConfig, containerName) ->
		_.compact _.flatten([
				'docker'
				'run'
				'-i'
				'--name', containerName
				'--net', 'none'
				'-v', sandboxPath + ':/vol/'
				'-u', '1000:1000'
				'tomlau10/sandbox-run'
				'-n', 1
				'-m', sandboxConfig.memoryLimitMB
				if sandboxConfig.language != 'c' then ['-c', sandboxConfig.codeFilename] else ''
				'-CR'
				sandboxConfig.executableFilename
			])

	makeRmCmd = (containerName) ->
		[
			'docker'
			'rm'
			'-f'
			containerName
		].join ' '

	self.runSandbox = (cmd, opt, containerName, done) ->
		childProcess.exec cmd, opt, (err, stdout, stderr) ->
			childProcess.exec makeRmCmd(containerName), (err, stdout, stderr) ->
				$.utils.onError _.noop, err if err && !/No such container/.test err.message

			done err, stdout, stderr

	self.compile = (sandboxPath, sandboxConfig, done) ->
		containerName = $.utils.rng.generateId()

		cmd = makeCompileCmd(sandboxPath, sandboxConfig, containerName)
		return done null if cmd == ''
		return done new Error("Compile command not found for language [#{sandboxConfig.language}].") if !cmd

		self.runSandbox cmd, {timeout: sandboxConfig.commandTimeoutMs}, containerName, (err, stdout, stderr) ->
			if stderr
				error = new Error("Compile Error: #{stderr}")
				error.compileErrorMessage = stderr
				return done error

			return $.utils.onError done, err if err
			done null

	self.compileAndRun = (sandboxPath, sandboxConfig, containerName, done) ->
		self.compile sandboxPath, sandboxConfig, (err) ->
			return done err if err
			cmd = makeRunCmd(sandboxPath, sandboxConfig, containerName)
			done null, childProcess.spawn _.head(cmd), _.tail(cmd)

	return self
