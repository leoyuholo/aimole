
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	_new = (newSubmission) ->
		submissionACL = new $.Parse.ACL()
		submissionACL.setPublicWriteAccess false
		submissionACL.setReadAccess newSubmission.userId, true
		new $.models.Submission()
			.set 'userId', newSubmission.userId
			.set 'displayName', newSubmission.displayName
			.set 'gameId', newSubmission.gameId
			.set 'language', newSubmission.language
			.set 'code', newSubmission.code
			.setACL submissionACL

	self.findById = (submissionId, done) ->
		new $.Parse.Query($.models.Submission)
			.get submissionId, {useMasterKey: true}
			.then (submission) -> done null, submission?.toJSON?()
			.fail (err) -> done err

	self.create = (newSubmission, done) ->
		_new(newSubmission)
			.save null, {useMasterKey: true}
			.then (submission) -> done null, submission?.toJSON?()
			.fail (err) -> done err

	self.addMatchId = (submissionId, matchId, done) ->
		new $.models.Submission({id: submissionId})
			.set 'matchId', matchId
			.save null, {useMasterKey: true}
			.then (submission) -> done null, submission?.toJSON?()
			.fail (err) -> done err

	return self
