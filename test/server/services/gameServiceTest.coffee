path = require 'path'

async = require 'async'
_ = require 'lodash'
fse = require 'fs-extra'

chai = require 'chai'
chai.use require 'sinon-chai'
should = chai.should()
helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'services', () ->
			describe.skip 'gameService', () ->
				$ = helper.getGlobals()

				it 'should run two-player game', (done) ->
					this.timeout 200000

					async.parallel [
						_.partial fse.readFile, path.join(__dirname, 'testData', 'two-player', 'verdict.py'), {encoding: 'utf8'}
						_.partial fse.readFile, path.join(__dirname, 'testData', 'two-player', 'player1.c'), {encoding: 'utf8'}
						_.partial fse.readFile, path.join(__dirname, 'testData', 'two-player', 'player2.c'), {encoding: 'utf8'}
					], (err, [verdictCode, player1Code, player2Code]) ->
						should.not.exist err

						match =
							game:
								verdict:
									language: 'python'
									code: verdictCode
							players: [
								{language: 'c', code: player1Code}
								{language: 'c', code: player2Code}
							]

						$.services.gameService.play match, {}, (err, result) ->
							should.not.exist err

							console.log 'gameServiceTest', result

							done null
