app = angular.module 'aimole'

app.controller 'adminController', ($scope, messageService, gameService) ->

	$scope.addGameMsg = {}
	$scope.addGameForm =
		url: ''

	$scope.addGame = (url) ->
		gameService.addGame url
			.then () -> messageService.success $scope.addGameMsg, 'Game added.'
			.fail (err) -> messageService.error $scope.addGameMsg, err.message
