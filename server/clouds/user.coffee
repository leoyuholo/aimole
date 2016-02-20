
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.beforeSave Parse.User, (req, res) ->
			$.logger.info 'before save user', req.object.get 'username'
			res.success()
