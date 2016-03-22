app = angular.module 'aimole'

app.service 'userService', ($rootScope, redirectService) ->
	self = {}

	self.getUser = () ->
		$rootScope.user = Parse.User.current()?.toJSON()

	self.signIn = (done) ->
		Parse.FacebookUtils.logIn null, {
			success: (user) ->
				$rootScope.user = self.getUser()
				done null, $rootScope.user
			error: (err) -> done err
		}

	self.logout = () ->
		Parse.User.logOut()
		$rootScope.user = ''

	return self
