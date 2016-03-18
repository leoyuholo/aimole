
chai = require 'chai'

chai.use require 'sinon-chai'
chai.use require 'chai-string'
should = chai.should()

helper = require '../helper'

describe 'aimole', () ->
	describe 'server', () ->
		describe 'services', () ->
			describe 'codeService', () ->
				$ = helper.getGlobals()

				describe 'analyse', () ->
					it 'should call callback without {ok: true} for non c languages', (done) ->
						$.services.codeService.analyse {}, 'javascript', 'console.log("hello world!");', (err, result) ->
							should.not.exist err

							result.ok.should.be.true

							done null

					it 'should call callback without compile error', (done) ->
						code = '#include <stdio.h>\nint main(){printf("hello world!\\n");}'
						$.services.codeService.analyse {}, 'c', code, (err, result) ->
							should.not.exist err

							result.ok.should.be.true

							done null

					it 'should call callback with compile error', (done) ->
						code = '#include <stdio.h>\nint main(){printf("hello world!\\n")}'
						$.services.codeService.analyse {}, 'c', code, (err, result) ->
							should.not.exist err

							result.ok.should.be.false
							result.errorMessage.should.equal 'Compile Error'
							result.compileErrorMessage.should.startWith 'code.c: In function \'main\''

							done null
