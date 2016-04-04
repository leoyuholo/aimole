app = angular.module 'aimole'

app.controller 'gameController', ($scope, $rootScope, $routeParams, $sce, messageService, parseService, modalService, matchService, analyticService) ->

	$scope.gameId = $routeParams.gameId

	$scope.game = {}
	$scope.gameMsg = {}
	$scope.runMsg = {}
	$scope.compileError = ''
	$scope.iframeUrl = ''

	$scope.code = ''
	$scope.codeTpl = ''
	$scope.codeLocalStorageKey = "game/#{$scope.gameId}"
	$scope.codeAceOptions =
		maxLines: Infinity
	timer = Date.now()
	$scope.editorOnChange = _.throttle ( () -> analyticService.trackActiveEditing $scope.game, timer), 10 * 60 * 1000

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

			messageService.success $scope.runMsg, 'Submitting...'
			matchService.newMatch $scope.gameId, players, myCode, (err, match) ->
				if err && /^Compile Error:/.test err.message
					messageService.error $scope.runMsg, 'Compile Error'
					$scope.compileError = err.message
					return
				return messageService.error $scope.runMsg, err.message if err

				messageService.success $scope.runMsg, 'Enjoy the game!'

				$scope.iframeUrl = ''
				viewData = if match.result && match.result.length > 0 then {display: JSON.stringify match.result} else {streamUrl: makeStreamUrl(), matchId: match.objectId}
				_.delay () -> $scope.iframeUrl = makeIframeUrl $scope.game.viewUrl, viewData

	findGame = (gameId) ->
		parseService.getCache "game-#{$scope.gameId}", (err, game) ->
			return messageService.error $scope.gameMsg, err.message if err

			$scope.game = game
			$scope.iframeUrl = makeIframeUrl $scope.game.viewUrl
			$scope.code = game.codeTpl?.c || '// Enter your code here' if !$scope.code

			analyticService.trackGame $scope.game, 'load'

	makeStreamUrl = () ->
		"#{window.location.origin}/match"

	makeIframeUrl = (baseUrl, hashObj) ->
		url = URI baseUrl
		url.protocol 'https' if window.location.protocol == 'https:'
		url.addFragment hashObj if hashObj
		$sce.trustAsResourceUrl url.toString()

	findGame $scope.gameId
