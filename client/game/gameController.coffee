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
			$scope.compileError = ''
			messageService.clear $scope.runMsg
			return messageService.error $scope.runMsg, err.message if err

			myCode =
				language: 'c'
				code: $scope.code

			async.waterfall [
				_.partial matchService.newMatch, $scope.gameId, players, myCode
				(matchId, done) ->
					messageService.success $scope.runMsg, 'Running...'
					done null, matchId
				matchService.playMatch
			], (err, match) ->
				if err && /^Compile Error:/.test err.message
					messageService.error $scope.runMsg, 'Compile Error'
					$scope.compileError = err.message
					return
				return messageService.error $scope.runMsg, err.message if err
				$scope.iframeUrl = $sce.trustAsResourceUrl $scope.game.viewUrl + '#display=' + encodeURIComponent JSON.stringify match.result
				messageService.clear $scope.runMsg

	findGame = (gameId) ->
		parseService.getCache "game-#{$scope.gameId}", (err, game) ->
			return messageService.error $scope.gameMsg, err.message if err

			$scope.game = game
			$scope.iframeUrl = $sce.trustAsResourceUrl game.viewUrl

	findGame $scope.gameId
