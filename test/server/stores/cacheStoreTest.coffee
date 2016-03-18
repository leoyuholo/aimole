
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

				describe 'first', () ->
					it 'should find no cache', (done) ->
						$.stores.cacheStore.first $.utils.rng.generateId(), (err, value) ->
							should.not.exist err

							should.not.exist value

							done null

					it 'should find foo', (done) ->
						$.stores.cacheStore.upsert 'foo', {foo: 'bar'}, (err, value) ->
							should.not.exist err

							$.stores.cacheStore.first 'foo', (err, value) ->
								should.not.exist err

								value.foo.should.equal 'bar'

								done null

					it 'should find someCount', (done) ->
						$.stores.cacheStore.increment 'someCount', (err, count) ->
							should.not.exist err

							$.stores.cacheStore.first 'someCount', (err, count) ->
								should.not.exist err

								count.should.equal 1

								done null

				describe 'upsert', () ->
					it 'should add cache', (done) ->
						$.stores.cacheStore.upsert 'foo', {foo: 'bar'}, (err, value) ->
							should.not.exist err

							value.foo.should.equal 'bar'

							done null

					it 'should update cache', (done) ->
						$.stores.cacheStore.upsert 'foo', {foo: 'bar'}, (err, value) ->
							should.not.exist err
							$.stores.cacheStore.upsert 'foo', {foo: 'baz'}, (err, value) ->
								should.not.exist err
								$.stores.cacheStore.first 'foo', (err, value) ->
									should.not.exist err

									value.foo.should.equal 'baz'

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

				describe 'addItem', () ->
					it 'should create a new array', (done) ->
						$.stores.cacheStore.addItem 'games', {name: 'tictactoe'}, (err, array) ->
							should.not.exist err

							array[0].should.be.deep.equal {name: 'tictactoe'}

							done null

					it 'should add item to an existing array', (done) ->
						$.stores.cacheStore.addItem 'games', {name: 'othello'}, (err, array) ->
							should.not.exist err

							array[0].should.be.deep.equal {name: 'tictactoe'}
							array[1].should.be.deep.equal {name: 'othello'}

							done null
