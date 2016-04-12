
_ = require 'lodash'
async = require 'async'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'installGame', (req, res) ->
			adminKey = req.params.adminKey
			return res.error 'Invalid adminKey.' if adminKey != $.config.adminKey

			githubUrl = req.params.githubUrl
			return res.error 'Invalid githubUrl. githubUrl is not a string.' if !_.isString githubUrl
			return res.error "Invalid githubUrl. githubUrl does not begin with 'https://github.com/'." if !_.startsWith githubUrl, 'https://github.com/'
			return res.error "Invalid githubUrl. githubUrl does not end with '.git'." if !_.endsWith githubUrl, '.git'

			async.waterfall [
				_.partial $.services.adminService.readGame, githubUrl
				$.services.adminService.installGame
			], (err, game) ->
				return res.error err.message if err
				res.success $.models.Game.envelop game
