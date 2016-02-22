app = angular.module 'aimole'

app.service 'userService', ($rootScope, redirectService) ->
	self = {}

	self.hasRole = (roleName) ->
		Parse.Cloud.run 'hasRole', {roleName: roleName}

	self.requireRole = (roleName) ->
		self.hasRole roleName
			.then (result) -> redirectService.redirectToHome() if !result
			.fail (err) -> redirectService.redirectToHome()

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
				user.setACL new Parse.ACL(user)
				role = new Parse.Role('Player')
				role.getUsers().add user
				role.save()
				user.save()

	self.logout = () ->
		Parse.User.logOut()

	return self
