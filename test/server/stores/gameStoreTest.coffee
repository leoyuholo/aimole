
_ = require 'lodash'
async = require 'async'
chai = require 'chai'

chai.use require 'sinon-chai'
should = chai.should()

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'stores', () ->
			describe 'gameStore', () ->
				$ = helper.getGlobals()

				before (done) ->
					async.series [
						_.partial helper.setupServer, $
						helper.cleanDB
					], done

				after (done) ->
					helper.cleanDB done

				describe 'findByGithubUrl', () ->
					it 'should find no games', (done) ->
						$.stores.gameStore.findByGithubUrl $.utils.rng.generateId(), (err, game) ->
							should.not.exist err

							should.not.exist game

							done null

					it 'should find a game', (done) ->
						newGame =
							githubUrl: 'https://github.com/leoyuholo/aimole-tictactoe.git'
							name: 'Tic-Tac-Toe'
							describe: 'Fun game.'
							author: ''
							version: '0.0.0'
							viewUrl: 'http://leoyuholo.github.io/aimole-tictactoe/'
							players: 2

						$.stores.gameStore.upsertByGithubUrl 'https://github.com/leoyuholo/aimole-tictactoe.git', newGame, (err, game) ->
							should.not.exist err

							game.should.not.be.null

							$.stores.gameStore.findByGithubUrl 'https://github.com/leoyuholo/aimole-tictactoe.git', (err, game) ->
								should.not.exist err

								game.githubUrl.should.equal newGame.githubUrl
								game.name.should.equal newGame.name
								game.describe.should.equal newGame.describe

								done null

				describe 'upsertByGithubUrl', () ->
					it 'should add game', (done) ->
						newGame =
							githubUrl: 'https://github.com/leoyuholo/aimole-tictactoe.git'
							name: 'Tic-Tac-Toe'
							describe: 'Fun game.'
							author: ''
							version: '0.0.0'
							viewUrl: 'http://leoyuholo.github.io/aimole-tictactoe/'
							players: 2

						$.stores.gameStore.upsertByGithubUrl 'https://github.com/leoyuholo/aimole-tictactoe.git', newGame, (err, game) ->
							should.not.exist err

							game.should.not.be.null

							done null

				describe 'list', () ->
					it 'should list games', (done) ->
						$.stores.gameStore.list (err, games) ->
							should.not.exist err

							games.should.be.an.array

							done null
