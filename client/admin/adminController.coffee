app = angular.module 'aimole'

app.controller 'adminController', ($scope, messageService, gameService) ->

	$scope.addGameMsg = {}
	$scope.addGameForm =
		url: ''

	$scope.addGame = (url) ->
		messageService.warning $scope.addGameMsg, 'Adding game... Please wait.'
		gameService.addGame url
			.then () -> messageService.success $scope.addGameMsg, 'Game added.'
			.fail (err) -> messageService.error $scope.addGameMsg, err.message
