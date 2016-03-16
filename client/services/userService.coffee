app = angular.module 'aimole'

app.service 'userService', ($rootScope, redirectService, facebookService) ->
	self = {}

	self.getUser = () ->
		$rootScope.user = Parse.User.current()?.toJSON()

	self.signIn = (done) ->
		async.series [
			facebookService.logIn
			facebookService.getUserProfile
		], (err, [user, profile]) ->
			return done err if err
			user.set 'displayName', profile.displayName
			user.set 'profilePictureUrl', profile.profilePictureUrl
			user.set 'facebookId', profile.facebookId
			user.save()
				.then (user) ->
					$rootScope.user = self.getUser()
					done null, user
				.fail (err) -> done err

	self.logout = () ->
		Parse.User.logOut()
		$rootScope.user = ''

	return self
