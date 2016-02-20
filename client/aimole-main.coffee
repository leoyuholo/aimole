app = angular.module 'aimole', ['ngRoute', 'ngCookies', 'ui.bootstrap', 'parse-angular']

app.run ($rootScope) ->
	Parse.initialize 'aimole'
	Parse.serverURL = "#{window.location.origin}/parse"

	user = new Parse.User()

	user.set 'username', 'leoyuholo'
	user.set 'password', 'password'
	user.set 'email', 'leoyuholo@gmail.com'

	user.signUp null
		.then (user) ->
			console.log 'signUp', user
		.fail (err) ->
			console.log 'signUp fail', err
