
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	_find = (gameId) ->
		new $.Parse.Query($.models.Profile)
			.equalTo 'gameId', gameId
			.find()

	_first = (gameId, userId) ->
		new $.Parse.Query($.models.Profile)
			.equalTo 'gameId', gameId
			.equalTo 'userId', userId
			.first()

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

	self.create = (newProfile, done) ->
		_new(newProfile)
			.then (profile) -> done null, profile?.toJSON()?
			.fail (err) -> done err

	self.addSubmission = (gameId, userId, submission, done) ->
		_first gameId, userId
			.then (profile) ->
				profile.add 'submissions', submission
					.save null, {useMasterKey: true}
					.then (profile) ->
						submissions = profile.get 'submissions'
						return profile if submissions.length <= 5
						excessSubmissions = _.take submissions, submissions.length - 5
						Promise.all _.map excessSubmissions, (s) -> profile.remove 'submissions', s
					.then (profile) -> done null, profile?.toJSON?()
			.fail (err) -> done err

	self.updateScoreIfHigher = (gameId, userId, score, done) ->
		_first gameId, userId
			.then (profile) ->
				return done null, profile?.toJSON?() if score <= profile.get 'score'
				profile.set 'score', score
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
