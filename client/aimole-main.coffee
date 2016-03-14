app = angular.module 'aimole', ['ngRoute', 'ngCookies', 'ui.bootstrap']

app.config ($routeProvider, $locationProvider) ->
	$routeProvider
		.when '/',
			controller: 'gamesController'
			templateUrl: 'views/games'
		# .when '/game/:gameId',
		# 	controller: 'gameController'
		# 	templateUrl: 'views/game'
		# .when '/replay/:gameId/:replayId',
		# 	controller: 'replayController'
		# 	templateUrl: 'views/replay'
		.otherwise
			redirectTo: '/'

	return

app.run ($rootScope, userService) ->
	console.log 'aimole init'
