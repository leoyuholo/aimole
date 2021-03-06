
chai = require 'chai'

chai.use require 'sinon-chai'
chai.use require 'chai-string'
should = chai.should()

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'services', () ->
			describe.skip 'adminService', () ->
				$ = helper.getGlobals()

				describe 'readGame', () ->
					it 'should read game from https://github.com/leoyuholo/aimole-tictactoe.git', (done) ->
						this.timeout 20000

						$.services.adminService.readGame 'https://github.com/leoyuholo/aimole-tictactoe.git', (err, gameConfig) ->
							should.not.exist err

							gameConfig.name.should.be.equal 'Tic-Tac-Toe'
							gameConfig.verdict.code.should.be.a.string
							gameConfig.ai[0].name.should.be.equal 'easyplayer'
							gameConfig.ai[0].code.should.be.a.string
							gameConfig.ai[1].name.should.be.equal 'normalplayer'
							gameConfig.ai[1].code.should.be.a.string
							gameConfig.ai[2].name.should.be.equal 'randomplayer'
							gameConfig.ai[2].code.should.be.a.string

							done null

					it 'should read game from https://github.com/leoyuholo/aimole-othello.git', (done) ->
						this.timeout 20000

						$.services.adminService.readGame 'https://github.com/leoyuholo/aimole-othello.git', (err, gameConfig) ->
							should.not.exist err

							gameConfig.codeTpl.should.have.property 'c'
								.that.is.startWith '#include <stdio.h>'

							done null
