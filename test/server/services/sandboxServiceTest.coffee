path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'
Q = require 'q'

chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

should = chai.should()
chai.use sinonChai

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'services', () ->
			describe 'sandboxService', () ->
				scriptName = 'services/sandboxService'
				scriptPath = helper.getScriptPath scriptName
				sandboxService = require(scriptPath)()

				describe 'GameEntity', () ->
					it 'should run process', (done) ->
						gameEntity = new sandboxService.GameEntity("coffee #{path.join __dirname, 'testData', 'gameEntityDummy.coffee'}")

						return Q.async( () ->
							(yield gameEntity.send 'hello', 1000).should.have.property('data').and.equal 'hello\n'
							(yield gameEntity.send 'world', 1000).should.have.property('data').and.equal 'world\n'
							(yield gameEntity.send 'error', 1000).should.have.property('errorMessage').and.equal 'error message: error\n'
							(yield gameEntity.send 'exit', 1000).should.have.property('exitCode').and.equal 1
							done null
						)()

				describe 'run', () ->
					this.timeout 20000
					player1Code = player2Code = verdictCode = ''

					before (done) ->
						async.parallel [
							_.partial fse.readFile, path.join __dirname, 'testData', 'player1.c'
							_.partial fse.readFile, path.join __dirname, 'testData', 'player2.c'
							_.partial fse.readFile, path.join __dirname, 'testData', 'verdict.js'
						], (err, [p1, p2, v]) ->
							should.not.exist err

							player1Code = p1
							player2Code = p2
							verdictCode = v

							done null

					it 'should run game', (done) ->
						sandboxService.run player1Code, player2Code, verdictCode, (err, verdictHistory) ->
							should.not.exist err

							console.log verdictHistory

							done null
