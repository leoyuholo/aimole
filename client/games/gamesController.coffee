app = angular.module 'aimole'

app.controller 'gamesController', ($scope, messageService, gameService) ->

	$scope.games = []
	$scope.gamesMsg = {}

	$scope.backgroundImageUrl = 'http://leoyuholo.com/aimole-othello/bg.png'

	listGames = () ->
		gameService.listGames()
			.then (games) -> $scope.games = games
			.fail (err) -> messageService.error gamesMsg, err.message

	listGames()
