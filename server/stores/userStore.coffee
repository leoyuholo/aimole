
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.list = (done) ->
		done = _.partial _.defer, done
		new $.Parse.Query($.Parse.User)
			.find {useMasterKey: true}
			.then (users) -> done null, _.invokeMap users, 'toJSON'
			.fail (err) -> done err

	return self
