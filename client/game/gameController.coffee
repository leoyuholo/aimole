app = angular.module 'aimole'

app.controller 'gameController', ($scope, $routeParams, $sce, messageService, gameService) ->

	$scope.gameObjectId = $routeParams.gameObjectId

	$scope.game = {}
	$scope.gameMsg = {}
	$scope.gameRunMsg = {}
	$scope.iframeUrl = ''

	$scope.code = ''
	$scope.codeLocalStorageKey = "game/#{$scope.gameObjectId}"
	$scope.codeAceOptions =
		maxLines: Infinity

	$scope.run = () ->
		players = [
			{code: $scope.code}
			{ai: 'normal'}
		]

		gameService.runGame $scope.gameObjectId, players
			.then (result) ->
				console.log JSON.stringify result
				$scope.iframeUrl = $sce.trustAsResourceUrl $scope.game.gameConfig.viewUrl + '#display=' + _.escape JSON.stringify result
			.fail (err) -> messageService.error $scope.gameRunMsg, err.message

	$scope.submit = () ->
		'Not implemented yet.'

	findGame = (gameObjectId) ->
		gameService.findGame gameObjectId
			.then (game) ->
				$scope.game = game
				$scope.iframeUrl = $sce.trustAsResourceUrl game.gameConfig.viewUrl
			.fail (err) -> messageService.error $scope.gameMsg, err.message

	findGame $scope.gameObjectId
