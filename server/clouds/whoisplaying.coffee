
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
				return res.success {users: [], userCount: 0} if userCount == 0

				if userCount <= 5
					userNos = _.shuffle _.range 1, userCount + 1
				else
					userNos = _.sampleSize _.range(1, userCount + 1), 5

				async.map userNos, $.stores.userStore.findByUserNo, (err, users) ->
					return res.error err.message if err

					result =
						users: _.map users, (u) -> _.pick u, ['facebookId', 'displayName']
						userCount: userCount

					res.success result
