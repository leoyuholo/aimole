app = angular.module 'aimole', ['ngRoute', 'ngCookies', 'ui.bootstrap', 'parse-angular']

app.config ($routeProvider, $locationProvider) ->
	$routeProvider
		.when '/',
			redirectTo: '/admin'
		.when '/admin',
			controller: 'adminController'
			templateUrl: 'views/admin'
		.when '/login',
			controller: 'loginController'
			templateUrl: 'views/login'
		.otherwise
			redirectTo: '/'

	return

app.run ($rootScope) ->
	Parse.initialize 'aimole'
	Parse.serverURL = "#{window.location.origin}/parse"
