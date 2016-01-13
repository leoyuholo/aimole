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

			describe 'easyplayer', () ->
				easyplayerFilename = 'easyplayer.c'
				containerName = 'easyplayertest'

				it 'should run', (done) ->
					this.timeout 20000
					dataHistory = []
					cmd = [
						'docker'
						'run'
						'-i'
						'--rm'
						'--name', containerName
						'--net', 'none'
						'--security-opt', 'apparmor:unconfined'
						'-v', gameDirPath + ':/vol/'
						'-u', '$(id -u):$(id -g)'
						'tomlau10/sandbox-run'
						'-n', 1
						'-c', easyplayerFilename
						'-CR'
						'easyplayer'
					].join ' '

					console.log cmd

					input = [
						'0 0 0 0 0 0 0 0 0'
						'1 2 0 0 0 0 0 0 0'
						'1 2 0 1 2 0 0 0 0'
					]

					i = 0

					childProcess.exec "docker rm -f #{containerName}", (err) ->

						easyplayer = childProcess.exec cmd

						easyplayerWrite = (str) ->
							console.log 'write', str
							easyplayer.stdin.write str + '\n'

						easyplayerWrite input[i]
						i += 1

						easyplayer.stdout.on 'data', (data) ->
							dataHistory.push data
							console.log 'data', dataHistory
							if i < input.length
								easyplayerWrite input[i]
								i += 1
							else
								childProcess.exec "docker rm -f #{containerName}", (err, stdout, stderr) ->
									console.log err, stdout, stderr
									easyplayer.stdout.removeAllListeners 'data'

						easyplayer.stderr.on 'data', (data) ->
							console.log 'easyplayer stderr', "[#{data}]"

						easyplayer.on 'exit', () ->
							console.log 'exit', dataHistory
							done null
