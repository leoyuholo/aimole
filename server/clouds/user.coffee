
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.afterSave Parse.User, (req, res) ->
			isNewUser = !req.object.existed()

			updateStatFunc = $.services.statService.updateUserStat
			updateStatFunc = $.services.statService.increseUserCount if isNewUser

			updateStatFunc (err) ->
				return res.error err.message if err
				res.success()
