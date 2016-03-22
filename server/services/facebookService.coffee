
request = require 'request'

module.exports = ($) ->
	self = {}

	self.getUsername = (facebookId, accessToken, done) ->
		request "https://graph.facebook.com/v2.5/#{facebookId}?access_token=#{accessToken}", (err, res, body) ->
			return $.utils.onError done, err if err

			try
				result = JSON.parse body
			catch e
				return done new Error('Response JSON cannot be parsed.')

			done null, result.name

	return self
