
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

				after (done) ->
					helper.cleanDB done

				describe 'find', () ->
					it 'should find no cache', (done) ->
						$.stores.cacheStore.find $.utils.rng.generateId(), (err, value) ->
							should.not.exist err

							should.not.exist value

							done null

					it 'should find foo', (done) ->
						$.stores.cacheStore.upsert 'foo', 'bar', (err, value) ->
							should.not.exist err

							$.stores.cacheStore.find 'foo', (err, value) ->
								should.not.exist err

								value.should.equal 'bar'

								done null

				describe 'upsert', () ->
					it 'should add cache', (done) ->
						$.stores.cacheStore.upsert 'foo', 'bar', (err, value) ->
							should.not.exist err

							value.should.equal 'bar'

							done null
