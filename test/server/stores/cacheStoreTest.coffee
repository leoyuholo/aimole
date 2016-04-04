
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

					it 'should add one more item to an existing array', (done) ->
						$.stores.cacheStore.addItem 'games', {name: '2048'}, (err, array) ->
							should.not.exist err

							array[0].should.be.deep.equal {name: 'tictactoe'}
							array[1].should.be.deep.equal {name: 'othello'}
							array[2].should.be.deep.equal {name: '2048'}

							done null

				describe 'setKey', () ->
					it 'should create a new object', (done) ->
						$.stores.cacheStore.setKey 'matchResults', '1', {bar: 1}, (err, object) ->
							should.not.exist err

							object['1'].bar.should.be.equal 1

							done null

					it 'should set key 2 to bar: 2', (done) ->
						$.stores.cacheStore.setKey 'matchResults', '2', {bar: 2}, (err, object) ->
							should.not.exist err

							object['1'].bar.should.be.equal 1
							object['2'].bar.should.be.equal 2

							done null
