
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'hasRole', (req, res) ->
			roleName = req.params.roleName
			user = req.user

			query = new Parse.Query(Parse.Role)
			query.equalTo 'name', roleName
			query.equalTo 'users', user

			query.first()
				.then (role) -> res.success !!role
				.fail (err) -> res.error err.message

		Parse.Cloud.beforeSave Parse.User, (req, res) ->
			$.logger.info 'before save user', req.object.get 'username'
			res.success()
