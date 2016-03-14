
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.find = (key, done) ->
		done = _.partial _.defer, done
		new $.Parse.Query($.models.Cache)
			.equalTo 'key', key
			.first()
			.then (cache) -> done null, if cache then cache.get 'value' else cache
			.fail (err) -> done err

	self.upsert = (key, value, done) ->
		done = _.partial _.defer, done
		new $.Parse.Query($.models.Cache)
			.equalTo 'key', key
			.first()
			.then (cache) ->
				cache = cache || new $.models.Cache()

				cacheACL = new $.Parse.ACL()
				cacheACL.setPublicReadAccess true
				cacheACL.setPublicWriteAccess false
				cache.setACL cacheACL

				cache.save {key: key, value: value}, {useMasterKey: true}
					.then (cache) -> done null, cache.get 'value'
			.fail (err) -> done err

	return self
