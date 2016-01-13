path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'

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

				describe 'run', () ->
					it 'should call callback', (done) ->
						this.timeout 20000
						sandboxService.run player1Code, player2Code, verdictCode, (err, verdictHistory) ->
							should.not.exist err

							console.log verdictHistory

							done null
