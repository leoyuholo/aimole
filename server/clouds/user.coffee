
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.beforeSave Parse.User, (req, res) ->
			return res.success() if !req.object.isNew()
			user = req.object.toJSON()
			facebookId = user.authData.facebook.id
			accessToken = user.authData.facebook.access_token

			$.services.facebookService.getUsername facebookId, accessToken, (err, username) ->
				return res.error err.message if err

				req.object.set 'facebookId', facebookId
					.set 'displayName', username
					.set 'profilePictureUrl', "https://graph.facebook.com/#{facebookId}/picture"

				res.success()

		Parse.Cloud.afterSave Parse.User, (req, res) ->
			return res.success() if req.object.existed()

			$.stores.cacheStore.increment 'userCount', (err, newCount) ->
				return res.error err.message if err

				req.object.set 'userNo', newCount
					.save null, {useMasterKey: true}
					.then (user) -> res.success()
					.fail (err) -> res.error err.message
