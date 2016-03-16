
_ = require 'lodash'
async = require 'async'
chai = require 'chai'

chai.use require 'sinon-chai'
should = chai.should()

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'stores', () ->
			describe 'cacheStore', () ->
				$ = helper.getGlobals()

				before (done) ->
					async.series [
						_.partial helper.setupServer, $
						helper.cleanDB
					], done

				describe 'find', () ->
					it 'should find no cache', (done) ->
						$.stores.cacheStore.find $.utils.rng.generateId(), (err, value) ->
							should.not.exist err

							should.not.exist value

							done null

					it 'should find foo', (done) ->
						$.stores.cacheStore.upsert 'foo', {foo: 'bar'}, (err, value) ->
							should.not.exist err

							$.stores.cacheStore.find 'foo', (err, value) ->
								should.not.exist err

								value.foo.should.equal 'bar'

								done null

				describe 'upsert', () ->
					it 'should add cache', (done) ->
						$.stores.cacheStore.upsert 'foo', {foo: 'bar'}, (err, value) ->
							should.not.exist err

							value.foo.should.equal 'bar'

							done null

				describe 'increment', () ->
					it 'should increase userCount', (done) ->
						$.stores.cacheStore.increment 'userCount', (err, count) ->
							should.not.exist err

							count.should.equal 1

							done null

					it 'should increase userCount to 2', (done) ->
						$.stores.cacheStore.increment 'userCount', (err, count) ->
							should.not.exist err

							count.should.equal 2

							done null

				describe 'findCount', () ->
					it 'should find userCount', (done) ->
						$.stores.cacheStore.findCount 'userCount', (err, count) ->
							should.not.exist err

							count.should.equal 2

							done null
