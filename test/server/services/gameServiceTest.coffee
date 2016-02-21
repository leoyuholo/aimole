
chai = require 'chai'

chai.use require 'sinon-chai'
chai.use require 'chai-fs'
should = chai.should()

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'services', () ->
			describe 'gameService', () ->
				$ = require helper.getScriptPath 'globals'

				describe 'install', () ->
					it 'should install https://github.com/leoyuholo/aimole-example.git', (done) ->
						this.timeout 10000

						$.services.gameService.install 'https://github.com/leoyuholo/aimole-example.git', (err, game) ->
							should.not.exist err

							game.tarFilePath.should.be.a.file().and.not.empty
							game.gameConfig.should.be.an.object

							done null
