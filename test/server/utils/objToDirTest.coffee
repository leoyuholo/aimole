path = require 'path'

chai = require 'chai'

chai.use require 'sinon-chai'
chai.use require 'chai-fs'
should = chai.should()

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'utils', () ->
			describe 'objToDir', () ->
				$ = helper.getGlobals()

				it 'should write one layer object structure to directory', (done) ->
					dir = path.join $.tmpDir, 'test', 'utils', 'objToDir', 'test0'
					obj =
						foo: 'bar'
						faz: 'baz'

					$.utils.objToDir dir, obj, (err) ->
						should.not.exist err

						path.join(dir, 'foo').should.have.content 'bar'
						path.join(dir, 'faz').should.have.content 'baz'

						done null

				it 'should write two layer object structure to directory', (done) ->
					dir = path.join $.tmpDir, 'test', 'utils', 'objToDir', 'test1'
					obj =
						foo:
							faz: 'baz'

					$.utils.objToDir dir, obj, (err) ->
						should.not.exist err

						path.join(dir, 'foo').should.be.a.directory
						path.join(dir, 'foo', 'faz').should.have.content 'baz'

						done null
