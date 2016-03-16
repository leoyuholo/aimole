app = angular.module 'aimole'

app.service 'facebookService', ($q) ->
	self = {}

	self.logIn = (done) ->
		Parse.FacebookUtils.logIn null, {
			success: (user) -> done null, user
			error: (err) -> done err
		}

	self.getUserProfile = (done) ->
		deferred = $q.defer()

		FB.api '/me', {fields: ['name', 'id']}, (res) ->
			return deferred.reject new Error('Invalid response from facebook.') if !res
			return deferred.reject res.error if res.error

			profile =
				facebookId: res.id
				displayName: res.name
				profilePictureUrl: "http://graph.facebook.com/#{res.id}/picture"

			deferred.resolve profile

		deferred.promise
			.then (profile) -> done null, profile
			.catch (err) -> done err

	return self
