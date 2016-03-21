app = angular.module 'aimole'

app.controller 'gameController', ($scope, $rootScope, $routeParams, $sce, messageService, parseService, modalService, matchService, analyticService) ->

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
	$scope.editorOnChange = _.throttle ( () -> analyticService.trackActiveEditing $scope.game), 10 * 60 * 1000

	playersLocalStorageKey = "players/#{$scope.gameId}"

	$scope.run = () ->
		analyticService.trackGame $scope.game, 'selectPlayer'

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
			analyticService.trackPlayers $scope.game, players

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
				# TODO: track how many user leaves before getting match result
				if err && /^Compile Error:/.test err.message
					messageService.error $scope.runMsg, 'Compile Error'
					$scope.compileError = err.message
					return
				return messageService.error $scope.runMsg, err.message if err
				$scope.iframeUrl = $sce.trustAsResourceUrl $scope.game.viewUrl.replace('http://', 'https://') + '#display=' + encodeURIComponent JSON.stringify match.result
				messageService.clear $scope.runMsg

	findGame = (gameId) ->
		parseService.getCache "game-#{$scope.gameId}", (err, game) ->
			return messageService.error $scope.gameMsg, err.message if err

			$scope.game = game
			$scope.iframeUrl = $sce.trustAsResourceUrl game.viewUrl.replace('http://', 'https://')

			analyticService.trackGame $scope.game, 'load'

	findGame $scope.gameId
