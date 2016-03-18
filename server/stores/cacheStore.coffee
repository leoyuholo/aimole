
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	_find = (tags) ->
		tags = {key: tags} if _.isString tags
		new $.Parse.Query($.models.Cache)
			.containsAll 'tags', _.map tags, (v, k) -> "#{k}:#{v}"
			.find()

	_first = (tags) ->
		tags = {key: tags} if _.isString tags
		new $.Parse.Query($.models.Cache)
			.containsAll 'tags', _.map tags, (v, k) -> "#{k}:#{v}"
			.first()

	_new = (tags) ->
		tags = {key: tags} if _.isString tags

		cacheACL = new $.Parse.ACL()
		cacheACL.setPublicReadAccess true
		cacheACL.setPublicWriteAccess false
		cache = new $.models.Cache()
		cache.setACL cacheACL

		cache.set 'tags', _.map tags, (v, k) -> "#{k}:#{v}"

		return cache

	self.first = (tags, done) ->
		done = _.partial _.defer, done
		_first tags
			.then (cache) -> done null, if cache then cache.get cache.get 'type' else cache
			.fail (err) -> done err

	self.find = (tags, done) ->
		done = _.partial _.defer, done
		_find tags
			.then (cache) -> done null, if cache then _.map cache, (c) -> c.get c.get 'type' else cache
			.fail (err) -> done err

	self.upsert = (tags, value, done) ->
		done = _.partial _.defer, done

		# ordering is important since array is also classified as object
		valueType = 'obj' if _.isObjectLike value
		valueType = 'arr' if _.isArray value
		valueType = 'str' if _.isString value
		valueType = 'num' if _.isNumber value

		return done new Error('Unknow cache type. Cache type must be one of [obj, arr, str, num].') if !valueType

		_first tags
			.then (cache) ->
				return done new Error('Cache type mismatch.') if cache && valueType != cache.get 'type'
				cache = cache || _new(tags)
				cache.set 'type', valueType
				cache.set valueType, value
				cache.save null, {useMasterKey: true}
					.then (cache) -> done null, cache.get valueType
			.fail (err) -> done err

	self.increment = (tags, done) ->
		done = _.partial _.defer, done
		_first tags
			.then (cache) ->
				return self.upsert tags, 1, done if !cache
				return done new Error("Cache type mismatch. Expect 'num' but get #{cache.get 'type'}.") if 'num' != cache.get 'type'
				cache.increment 'num'
					.save null, {useMasterKey: true}
					.then (cache) -> done null, cache.get 'num'
			.fail (err) -> done err

	self.addItem = (tags, item, done) ->
		done = _.partial _.defer, done
		_first tags
			.then (cache) ->
				return self.upsert tags, [item], done if !cache
				return done new Error("Cache type mismatch. Expect 'arr' but get #{cache.get 'type'}.") if 'arr' != cache.get 'type'
				# workaround, lose atomicity
				# cache.add item
				cache.set 'arr', cache.get('arr').concat [item]
					.save null, {useMasterKey: true}
					.then (cache) -> done null, cache.get 'arr'
			.fail (err) -> done err

	return self
