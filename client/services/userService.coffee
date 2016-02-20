app = angular.module 'aimole'

app.service 'userService', ($rootScope) ->
	self = {}

	self.getUser = () ->
		Parse.User.current()

	self.login = (email, password) ->
		Parse.User.logIn email, password

	self.signup = (email, password) ->
		user = new Parse.User()

		user.set 'username', email
		user.set 'password', password
		user.set 'email', email

		user.signUp null
			.then (user) ->
				user.setACL new Parse.ACL user
				user.save()

	self.logout = () ->
		Parse.User.logOut()

	return self
