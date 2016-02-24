app = angular.module 'aimole', ['ngRoute', 'ngCookies', 'ui.bootstrap', 'parse-angular', 'fillHeight', 'ui.ace']

app.config ($routeProvider, $locationProvider) ->
	$routeProvider
		.when '/',
			redirectTo: '/games'
		.when '/admin',
			controller: 'adminController'
			templateUrl: 'views/admin'
		.when '/login',
			controller: 'loginController'
			templateUrl: 'views/login'
		.when '/games',
			controller: 'gamesController'
			templateUrl: 'views/games'
		.when '/game/:objectId',
			controller: 'gameController'
			templateUrl: 'views/game'
		.otherwise
			redirectTo: '/'

	return

app.run ($rootScope, userService) ->
	Parse.initialize 'aimole'
	Parse.serverURL = "#{window.location.origin}/parse"

	$rootScope.requireRole = userService.requireRole
