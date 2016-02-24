app = angular.module 'aimole'

app.controller 'gameController', ($scope, $routeParams, $sce, messageService, gameService) ->

	$scope.objectId = $routeParams.objectId

	$scope.game = {}
	$scope.gameRunMsg = {}
	$scope.iframeUrl = $sce.trustAsResourceUrl 'http://www.w3schools.com/html/html_iframe.asp'

	$scope.code = ''
	$scope.codeLocalStorageKey = "game/#{$scope.objectId}"
	$scope.codeAceOptions =
		maxLines: Infinity

	$scope.run = () ->
		'Not implemented yet.'

	$scope.submit = () ->
		'Not implemented yet.'

	findGame = (objectId) ->
		gameService.findGame objectId
			.then (game) -> $scope.game = game
			.fail (err) -> messageService.error gameMsg, error.message

	findGame $scope.objectId
