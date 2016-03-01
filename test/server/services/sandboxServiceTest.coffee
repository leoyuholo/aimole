
chai = require 'chai'

chai.use require 'sinon-chai'
chai.use require 'chai-fs'
should = chai.should()

helper = require '../helper'

path = require 'path'

async = require 'async'
_ = require 'lodash'
fse = require 'fs-extra'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'services', () ->
			describe 'sandboxService', () ->
				$ = require helper.getScriptPath 'globals'

				describe.only 'runGame', () ->
					it 'should run game', (done) ->
						this.timeout 200000

						async.parallel [
							_.partial fse.readFile, path.join __dirname, 'testData', 'sandboxServiceTest', 'verdict.py'
							_.partial fse.readFile, path.join __dirname, 'testData', 'sandboxServiceTest', 'player1.c'
							_.partial fse.readFile, path.join __dirname, 'testData', 'sandboxServiceTest', 'player2.c'
						], (err, [verdictCode, player1Code, player2Code]) ->
							should.not.exist err

							verdictConfig =
								code: verdictCode
								language: 'python'

							player1Config =
								code: player1Code
								language: 'c'

							player2Config =
								code: player1Code
								language: 'c'

							$.services.sandboxService.runGame verdictConfig, [player1Config, player2Config], (err, verdictHistory) ->
								should.not.exist err

								verdictHistory.should.be.instanceof Array
								verdictHistory[0].should.have.property('type')
									.that.equal 'command'

								console.log verdictHistory

								# _.last verdictHistory
								# 	.should.have.property 'data'
								# 	.that.have.property 'action'
								# 	.that.equal 'stop'

								done null
