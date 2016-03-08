app = angular.module 'aimole'

app.controller 'gamesController', ($scope, messageService, gameService) ->

	$scope.games = []
	$scope.gamesMsg = {}

	$scope.backgroundImageUrl = 'http://www.wallpaperjosh.xyz/wp-content/uploads/2016/01/1920x1080-hd-wallpaper-JK009.jpg'

	listGames = () ->
		gameService.listGames()
			.then (games) -> $scope.games = games
			.fail (err) -> messageService.error gamesMsg, err.message

	listGames()
