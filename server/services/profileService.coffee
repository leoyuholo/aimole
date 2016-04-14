
module.exports = ($) ->
	self = {}

	self.addIfNotExist = (newProfile, done) ->
		$.stores.profileStore.findByGameIdAndUserId newProfile.gameId, newProfile.userId, (err, profile) ->
			return $.utils.onError done, err if err
			return done null, profile if profile

			$.userStore.findById newProfile.userId, (err, user) ->
				return $.utils.onError done, err if err
				return $.utils.onError done, new Error('User not found.') if !user

				newProfile.profilePictureUrl = user.profilePictureUrl

				$.profileStore.create newProfile, done

	return self
