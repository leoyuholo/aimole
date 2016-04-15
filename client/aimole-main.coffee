app = angular.module 'aimole', ['ngRoute', 'ngCookies', 'ui.bootstrap', 'parse-angular', 'ui.ace', '720kb.background', 'angulartics', 'angulartics.google.analytics']

app.config ($routeProvider, $locationProvider) ->
	$routeProvider
		.when '/',
			controller: 'gamesController'
			templateUrl: 'views/games'
		.when '/game/:gameId/:matchId?',
			controller: 'gameController'
			templateUrl: 'views/game'
		.otherwise
			redirectTo: '/'

	return

Parse.initialize 'aimole'
Parse.serverURL = "#{window.location.origin}/parse"

app.run ($rootScope, userService, analyticService) ->
	userService.getUser()

	analyticService.setUserId()
