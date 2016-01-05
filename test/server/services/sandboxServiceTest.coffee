
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

				describe 'run', () ->
					it 'should call callback', (done) ->
						sandboxService.run () ->
							true.should.be.true
							done null
