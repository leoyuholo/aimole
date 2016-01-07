
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
				gameService = require(scriptPath)(helper.getGlobalsStub())

				describe 'list', () ->
					it 'should have list function', () ->
						gameService.list.should.be.a.function
