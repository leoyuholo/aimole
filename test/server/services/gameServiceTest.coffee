
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

should = chai.should()
chai.use sinonChai

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'services', () ->
			describe 'gameService', () ->
				scriptName = 'services/gameService'
				scriptPath = helper.getScriptPath scriptName
				gameService = require scriptPath

				describe 'list', () ->
					it 'should call callback with an array', (done) ->
						gameService.list (err, games) ->
							games.should.be.an.array
							done null
