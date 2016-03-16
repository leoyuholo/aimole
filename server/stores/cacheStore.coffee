
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	_find = (key) ->
		new $.Parse.Query($.models.Cache)
			.equalTo 'key', key
			.first()

	_new = () ->
		cacheACL = new $.Parse.ACL()
		cacheACL.setPublicReadAccess true
		cacheACL.setPublicWriteAccess false
		cache = new $.models.Cache()
		cache.setACL cacheACL
		return cache

	self.find = (key, done) ->
		done = _.partial _.defer, done
		_find key
			.then (cache) -> done null, if cache then JSON.parse cache.get 'value' else cache
			.fail (err) -> done err

	self.upsert = (key, value, done) ->
		done = _.partial _.defer, done
		_find key
			.then (cache) ->
				cache = cache || _new()

				cache.save {key: key, value: JSON.stringify value}, {useMasterKey: true}
					.then (cache) -> done null, JSON.parse cache.get 'value'
			.fail (err) -> done err

	self.increment = (key, done) ->
		done = _.partial _.defer, done
		_find key
			.then (cache) ->
				if cache
					cache.increment 'count'
						.save null, {useMasterKey: true}
						.then (cache) -> done null, cache.get 'count'
				else
					cache = _new()

					cache.save {key: key, count: 1}, {useMasterKey: true}
						.then (cache) -> done null, cache.get 'count'

	self.findCount = (key, done) ->
		done = _.partial _.defer, done
		_find key
			.then (cache) -> done null, if cache then cache.get 'count' else 0
			.fail (err) -> done err

	return self
