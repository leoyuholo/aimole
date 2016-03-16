app = angular.module 'aimole'

app.service 'parseService', () ->
	self = {}

	Cache = Parse.Object.extend 'Cache'

	self.getCache = (key, done) ->
		new Parse.Query(Cache)
			.equalTo 'key', key
			.first()
			.then (cache) -> done null, if cache then JSON.parse cache.get 'value' else cache
			.fail (err) -> done err

	self.getCount = (key, done) ->
		new Parse.Query(Cache)
			.equalTo 'key', key
			.first()
			.then (cache) -> done null, if cache then cache.get 'count' else 0
			.fail (err) -> done err

	self.run = (key, data, done) ->
		Parse.Cloud.run key, data
			.then (result) -> done null, result
			.fail (err) -> done err

	return self
