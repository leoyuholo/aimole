
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.updateUserStat = (done) ->
		$.stores.userStore.list (err, users) ->
			return $.utils.onError done, err if err
			users = _.map users, (user) -> _.pick user, ['facebookId', 'displayName']

			$.stores.cacheStore.upsert 'users', users, done

	self.increseUserCount = (done) ->
		$.stores.cacheStore.increment 'userCount', done

	return self
