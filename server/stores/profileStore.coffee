
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	_find = (gameId) ->
		new $.Parse.Query($.models.Profile)
			.equalTo 'gameId', gameId
			.find {useMasterKey: true}

	_first = (gameId, userId) ->
		new $.Parse.Query($.models.Profile)
			.equalTo 'gameId', gameId
			.equalTo 'userId', userId
			.first {useMasterKey: true}

	_new = (newProfile) ->
		profileACL = new $.Parse.ACL()
		profileACL.setReadAccess newProfile.userId, true
		profileACL.setPublicWriteAccess false
		profile = new $.models.Profile()
		profile.setACL profileACL

		profile.set 'gameId', newProfile.gameId
			.set 'userId', newProfile.userId
			.set 'displayName', newProfile.displayName
			.set 'pictureUrl', newProfile.pictureUrl || ''
			.set 'ai', newProfile.ai || false
			.set 'submissions', []
			.set 'score', newProfile.score

	self.findByGameIdAndUserId = (gameId, userId, done) ->
		_first gameId, userId
			.then (profile) ->
				done null, profile?.toJSON?()
			.fail (err) -> done err

	self.listByGameId = (gameId, done) ->
		_find gameId
			.then (profiles) -> done null, _.compact _.map profiles, (p) -> p?.toJSON?()
			.fail (err) -> done err

	self.listByGameIdSortByScoreWithLimit = (gameId, limit, done) ->
		new $.Parse.Query($.models.Profile)
			.equalTo 'gameId', gameId
			.descending 'score'
			.limit limit
			.find {useMasterKey: true}
			.then (profiles) -> done null, _.compact _.map profiles, (p) -> p?.toJSON?()
			.fail (err) -> done err

	self.create = (newProfile, done) ->
		_new(newProfile)
			.save null, {useMasterKey: true}
			.then (profile) -> done null, profile?.toJSON?()
			.fail (err) -> done err

	self.setLastSubmissionId = (gameId, userId, submissionId, done) ->
		_first gameId, userId
			.then (profile) ->
				profile.set 'lastSubmissionId', submissionId
					.save null, {useMasterKey: true}
					.then (profile) -> done null, profile?.toJSON?()
			.fail (err) -> done err

	self.addSubmission = (gameId, userId, submission, done) ->
		_first gameId, userId
			.then (profile) ->
				profile.add 'submissions', submission
					.save null, {useMasterKey: true}
					.then (profile) -> done null, profile?.toJSON?()
			.fail (err) -> done err

	self.updateScoreIfHigher = (gameId, userId, score, submission, done) ->
		_first gameId, userId
			.then (profile) ->
				return done null, profile?.toJSON?() if score <= profile.get 'score'
				profile.set 'score', score
					.set 'submissions', [submission]
					.save null, {useMasterKey: true}
					.then (profile) -> done null, profile?.toJSON?()
			.fail (err) -> done err

	self.incrementScore = (gameId, userId, increment, done) ->
		_first gameId, userId
			.then (profile) ->
				profile.increment 'score', increment
					.save null, {useMasterKey: true}
					.then (profile) -> done null, profile?.toJSON?()
			.fail (err) -> done err

	return self
