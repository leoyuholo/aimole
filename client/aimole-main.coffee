app = angular.module 'aimole', ['ngRoute', 'ngCookies', 'ui.bootstrap', 'parse-angular', 'ui.ace', '720kb.background']

app.config ($routeProvider, $locationProvider) ->
	$routeProvider
		.when '/',
			controller: 'gamesController'
			templateUrl: 'views/games'
		.when '/game/:gameId',
			controller: 'gameController'
			templateUrl: 'views/game'
		# .when '/replay/:gameId/:replayId',
		# 	controller: 'replayController'
		# 	templateUrl: 'views/replay'
		.otherwise
			redirectTo: '/'

	return

Parse.initialize 'aimole'
Parse.serverURL = "#{window.location.origin}/parse"

app.run ($rootScope, userService) ->
	$rootScope.user = userService.getUser()
