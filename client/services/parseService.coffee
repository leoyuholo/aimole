app = angular.module 'aimole'

app.service 'parseService', () ->
	self = {}

	Cache = Parse.Object.extend 'Cache'

	_first = (tags) ->
		tags = {key: tags} if _.isString tags
		new Parse.Query(Cache)
			.containsAll 'tags', _.map tags, (v, k) -> "#{k}:#{v}"
			.first()

	self.getCache = (tags, done) ->
		_first tags
			.then (cache) -> done null, if cache then cache.get cache.get 'type' else cache
			.fail (err) -> done err

	self.run = (key, data, done) ->
		Parse.Cloud.run key, data
			.then (result) -> done null, result
			.fail (err) -> done err

	return self
