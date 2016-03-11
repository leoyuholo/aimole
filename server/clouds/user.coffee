
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'hasRole', (req, res) ->
			roleName = req.params.roleName
			user = req.user

			return res.success false if !user

			query = new Parse.Query(Parse.Role)
			query.equalTo 'name', roleName
			query.equalTo 'users', user

			query.first {useMasterKey: true}
				.then (role) -> res.success !!role
				.fail (err) -> res.error err.message

		Parse.Cloud.beforeSave Parse.User, (req, res) ->
			$.logger.info 'before save user', req.object.get 'username'
			res.success()
