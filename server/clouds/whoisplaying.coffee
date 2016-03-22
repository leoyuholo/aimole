
_ = require 'lodash'
async = require 'async'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'whoisplaying', (req, res) ->
			# userId = req.user?.id || 'anonymous'
			# displayName = req.user?.get? 'displayName' || 'Anonymous'
			# TODO: log who is calling this
			$.stores.cacheStore.first 'userCount', (err, userCount) ->
				return res.error err.message if err

				userNos = _.map _.range(0, _.min [userCount, 5]), _.partial _.random, 1, userCount

				async.map userNos, $.stores.userStore.findByUserNo, (err, users) ->
					return res.error err.message if err

					result =
						users: _.map users, (u) -> _.pick u, ['facebookId', 'displayName']
						userCount: userCount

					res.success result
