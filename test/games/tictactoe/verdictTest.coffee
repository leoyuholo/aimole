path = require 'path'
childProcess = require 'child_process'

Q = require 'q'

chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

should = chai.should()
chai.use sinonChai

helper = require '../helper'

describe 'aimole', () ->
	describe 'games', () ->
		describe 'tictactoe', () ->
			gameDirName = 'tictactoe'
			gameDirPath = helper.getScriptPath gameDirName

			describe 'verdict', () ->
				verdictFilename = 'verdict.c'

				it 'should run', (done) ->
					this.timeout 20000
					dataHistory = []
					cmd = [
						'docker'
						'run'
						'-i'
						'--rm'
						'--net', 'none'
						'--security-opt', 'apparmor:unconfined'
						'-v', gameDirPath + ':/vol/'
						'-u', '$(id -u):$(id -g)'
						'tomlau10/sandbox-run'
						'-n', 1
						'-c', verdictFilename
						'-CR'
						'verdict'
					].join ' '

					console.log cmd

					input = [
						{command: 'start'}
						{command: 'player', player: 0, time: 2, stdout: '0 0\n'}
						{command: 'player', player: 1, time: 2, stdout: '0 1\n'}
						{command: 'player', player: 0, time: 2, stdout: '1 0\n'}
						{command: 'player', player: 1, time: 1, stdout: '1 1\n'}
						{command: 'player', player: 0, time: 2, stdout: '2 0\n'}
					]

					i = 0

					verdict = childProcess.exec cmd

					verdictWrite = (str) ->
						console.log str
						verdict.stdin.write str + '\n'

					verdictWrite JSON.stringify input[i]
					i += 1

					verdict.stdout.on 'data', (data) ->
						dataHistory.push data
						if i < input.length
							verdictWrite JSON.stringify input[i]
							i += 1

					verdict.stderr.on 'data', (data) ->
						console.log 'stderr', data

					verdict.on 'exit', () ->
						console.log 'exit', dataHistory
						done null
