app = angular.module 'aimole'

app.controller 'gameController', ($scope, $rootScope, $routeParams, $sce, messageService, parseService, modalService, matchService) ->

	$scope.gameId = $routeParams.gameId

	$scope.game = {}
	$scope.gameMsg = {}
	$scope.runMsg = {}
	$scope.compileError = ''
	$scope.iframeUrl = ''

	$scope.code = ''
	$scope.codeLocalStorageKey = "game/#{$scope.gameId}"
	$scope.codeAceOptions =
		maxLines: Infinity

	playersLocalStorageKey = "players/#{$scope.gameId}"

	$scope.run = () ->
		$scope.compileError = ''
		messageService.clear $scope.runMsg

		modalOptions =
			templateUrl: 'views/playMatchModal'
			controller: 'playMatchModalController'
			animation: false
			size: 'md'
			backdrop: false
			resolve:
				game: () -> $scope.game
				playersLocalStorageKey: () -> playersLocalStorageKey

		modalService.openModal modalOptions, (err, players) ->
			return messageService.error $scope.runMsg, err.message if err

			myCode =
				language: 'c'
				code: $scope.code

			async.waterfall [
				_.partial matchService.newMatch, $scope.gameId, players, myCode
				matchService.playMatch
			], (err, result) ->
				return messageService.error $scope.runMsg, err.message if err
				$scope.iframeUrl = $sce.trustAsResourceUrl $scope.game.viewUrl + '#display=' + encodeURIComponent JSON.stringify result

	findGame = (gameId) ->
		parseService.getCache "game-#{$scope.gameId}", (err, game) ->
			return messageService.error $scope.gameMsg, err.message if err

			$scope.game = game
			$scope.iframeUrl = $sce.trustAsResourceUrl game.viewUrl

	findGame $scope.gameId
