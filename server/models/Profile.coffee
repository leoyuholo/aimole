
_ = require 'lodash'
Parse = require 'parse/node'

module.exports = ($) ->

	profileSchema =
		gameId: {type: String, required: true}
		userId: {type: String, required: true}
		displayName: {type: String, required: true}
		pictureUrl: {type: String}
		ai: {type: Boolean, default: false}
		submissions: [
			{
				submissionId: {type: String, required: true}
				matchId: {type: String, required: true}
				players: [
					{name: String}
				]
				updatedAt: {type: Date, required: true}
			}
		]
		lastSubmissionId: {type: String, required: true}
		score: {type: Number, default: 0}

	Profile = Parse.Object.extend 'Profile'

	Profile.schema = profileSchema

	Profile.parsePermissions = $.constants.parsePermissions.grantFindOnly

	Profile.envelop = (profile) ->
		slim = _.pick profile, ['objectId', 'gameId', 'userId', 'displayName', 'score']
		slim.submissions = [_.last profile.submissions]
		return slim

	return Profile
