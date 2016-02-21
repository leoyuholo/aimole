path = require 'path'

async = require 'async'
_ = require 'lodash'
fse = require 'fs-extra'

chai = require 'chai'

chai.use require 'sinon-chai'
chai.use require 'chai-fs'
should = chai.should()

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'utils', () ->
			describe 'tar', () ->
				$ = require helper.getScriptPath 'globals'
				tmpDir = path.join $.tmpDir, 'test', 'server', 'utils', 'tar'

				afterEach (done) ->
					fse.remove tmpDir, done

				describe 'targz', () ->
					it 'should create .tar.gz file', (done) ->
						src = __dirname
						dst = path.join tmpDir, 'test.tar.gz'
						$.utils.tar.targz src, dst, (err) ->
							should.not.exist err

							dst.should.be.a.file().and.not.empty

							done null

				describe 'untargz', () ->
					it 'should untar .tar.gz', (done) ->
						targzSrc = __dirname
						targzDst = untargzSrc = path.join tmpDir, 'test.tar.gz'
						untargzDst = path.join tmpDir, 'test'

						async.series [
							_.partial $.utils.tar.targz, targzSrc, targzDst
							_.partial $.utils.tar.untargz, untargzSrc, untargzDst
						], (err) ->
							should.not.exist err

							path.join(untargzDst, 'tarTest.coffee').should.be.a.file()

							done null
