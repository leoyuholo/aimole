
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

				describe 'runGame', () ->
					it 'should run game', (done) ->
						this.timeout 200000

						async.parallel [
							_.partial fse.readFile, path.join __dirname, 'testData', 'sandboxServiceTest', 'twoplayers', 'verdict.py'
							_.partial fse.readFile, path.join __dirname, 'testData', 'sandboxServiceTest', 'twoplayers', 'player1.c'
							_.partial fse.readFile, path.join __dirname, 'testData', 'sandboxServiceTest', 'twoplayers', 'player2.c'
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

								# console.log JSON.stringify _.map _.map(_.filter(verdictHistory, (r) -> r.type == 'action'), 'data'), 'display'
								console.log verdictHistory

								# _.last verdictHistory
								# 	.should.have.property 'data'
								# 	.that.have.property 'action'
								# 	.that.equal 'stop'

								done null

					it 'should run single player game', (done) ->
						this.timeout 2000000

						async.parallel [
							_.partial fse.readFile, path.join __dirname, 'testData', 'sandboxServiceTest', 'oneplayer', 'verdict.py'
							_.partial fse.readFile, path.join __dirname, 'testData', 'sandboxServiceTest', 'oneplayer', 'player1.c'
						], (err, [verdictCode, player1Code]) ->
							should.not.exist err

							verdictConfig =
								code: verdictCode
								language: 'python'

							player1Config =
								code: player1Code
								language: 'c'

							$.services.sandboxService.runGame verdictConfig, [player1Config], (err, verdictHistory) ->
								should.not.exist err

								verdictHistory.should.be.instanceof Array
								verdictHistory[0].should.have.property('type')
									.that.equal 'command'

								# console.log JSON.stringify _.map _.map(_.filter(verdictHistory, (r) -> r.type == 'action'), 'data'), 'display'
								console.log verdictHistory

								# _.last verdictHistory
								# 	.should.have.property 'data'
								# 	.that.have.property 'action'
								# 	.that.equal 'stop'

								done null
