
module.exports = ($) ->
	self = {}

	self.findRecentMatch = (gameId, userId, done) ->
		$.stores.profileStore.findByGameIdAndUserId newProfile.gameId, newProfile.userId, (err, profile) ->
			return $.utils.onError done, err if err
			return done null if !profile
			return done null if profile.submissions.length < 1

			$.stores.matchStore.findById profile.submissions[0].matchId, done

	self.addIfNotExist = (newProfile, done) ->
		$.stores.profileStore.findByGameIdAndUserId newProfile.gameId, newProfile.userId, (err, profile) ->
			return $.utils.onError done, err if err
			return done null, profile if profile

			return $.stores.profileStore.create newProfile, done if newProfile.ai

			$.stores.userStore.findById newProfile.userId, (err, user) ->
				return $.utils.onError done, err if err
				return $.utils.onError done, new Error('User not found.') if !user

				newProfile.profilePictureUrl = user.profilePictureUrl

				$.stores.profileStore.create newProfile, done

	return self
