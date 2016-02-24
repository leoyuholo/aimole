app = angular.module 'aimole'

app.controller 'gamesController', ($scope, messageService, gameService) ->

	$scope.games = []
	$scope.gamesMsg = {}

	listGames = () ->
		gameService.listGames()
			.then (games) -> $scope.games = games
			.fail (err) -> messageService.error gamesMsg, err.message

	listGames()
