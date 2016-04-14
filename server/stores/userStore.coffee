
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.findByUserNo = (userNo, done) ->
		new $.Parse.Query($.Parse.User)
			.equalTo 'userNo', userNo
			.first {useMasterKey: true}
			.then (user) -> done null, user.toJSON()
			.fail (err) -> done err

	self.findById = (userId, done) ->
		new $.Parse.Query($.Parse.User)
			.equalTo 'id', userId
			.first {useMasterKey: true}
			.then (user) -> done null, user?.toJSON?()
			.fail(err) -> done err

	self.list = (done) ->
		new $.Parse.Query($.Parse.User)
			.find {useMasterKey: true}
			.then (users) -> done null, _.invokeMap users, 'toJSON'
			.fail (err) -> done err

	return self
