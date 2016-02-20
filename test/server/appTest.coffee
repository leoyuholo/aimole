
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

should = chai.should()
chai.use sinonChai

describe 'aimole', () ->
	it 'should be ok', () ->
		true.should.be.true
