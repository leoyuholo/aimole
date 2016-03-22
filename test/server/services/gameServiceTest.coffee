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
			describe 'gameService', () ->
				$ = helper.getGlobals()
				verdict = {}
				players = []

				before (done) ->
					async.parallel [
						_.partial fse.readFile, path.join(__dirname, 'testData', 'two-player', 'verdict.py'), {encoding: 'utf8'}
						_.partial fse.readFile, path.join(__dirname, 'testData', 'two-player', 'player1.c'), {encoding: 'utf8'}
						_.partial fse.readFile, path.join(__dirname, 'testData', 'two-player', 'player2.c'), {encoding: 'utf8'}
					], (err, [verdictCode, player1Code, player2Code]) ->
						should.not.exist err

						verdict =
							language: 'python'
							code: verdictCode

						players = [
							{language: 'c', code: player1Code}
							{language: 'c', code: player2Code}
						]

						done null


				it 'should run two-player game', (done) ->
					this.timeout 200000

					match =
						game:
							verdict: _.cloneDeep verdict
						players: [
							_.cloneDeep players[0]
							_.cloneDeep players[1]
						]

					$.services.gameService.play match, {}, (err, result) ->
						should.not.exist err

						console.log 'two-player', result

						done null

				it.only 'should run error-player-1 game', (done) ->
					this.timeout 200000

					fse.readFile path.join(__dirname, 'testData', 'error-player-1', 'player1.c'), {encoding: 'utf8'}, (err, player1Code) ->
						should.not.exist err

						match =
							game:
								verdict: _.cloneDeep verdict
							players: [
								{language: 'c', code: player1Code}
								_.cloneDeep players[1]
							]

						$.services.gameService.play match, {}, (err, result) ->
							should.not.exist err

							console.log 'error-player-1', helper.inspect result

							result[2].should.have.property 'command'
								.that.has.property 'signalStr'
								.that.is.equal 'Runtime Error'

							done null
