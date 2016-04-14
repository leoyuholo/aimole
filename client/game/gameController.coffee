app = angular.module 'aimole'

app.controller 'gameController', ($scope, $rootScope, $routeParams, $sce, messageService, parseService, modalService, matchService, analyticService) ->

	$scope.gameId = $routeParams.gameId

	$scope.game = {}
	$scope.gameMsg = {}
	$scope.runMsg = {}
	$scope.iframeUrl = ''
	$scope.bgUrl = ''

	$scope.code = ''
	$scope.codeTpl = ''
	$scope.codeLocalStorageKey = "game/#{$scope.gameId}"
	$scope.codeAceOptions =
		maxLines: Infinity
	timer = Date.now()
	$scope.editorOnChange = _.throttle ( () -> analyticService.trackActiveEditing $scope.game, timer), 10 * 60 * 1000

	playersLocalStorageKey = "players/#{$scope.gameId}"

	$scope.showLeaderBoard = () ->
		analyticService.trackGame $scope.game, 'showLeaderBoard'

		modalOptions =
			templateUrl: 'views/leaderBoardModal'
			controller: 'leaderBoardModalController'
			animation: false
			size: 'lg'
			resolve:
				game: () -> $scope.game

		modalService.openModal modalOptions, (err, matchId) ->
			matchService.playMatch matchId, (err, match) ->
				return messageService.error $scope.runMsg, err.message if err
				updateIframeUrl match

	makeStreamUrl = () ->
		"#{window.location.origin}/match"

	makeIframeUrl = (baseUrl, params) ->
		baseUrl.replace /^http:/, 'https:' if window.location.protocol == 'https:'
		hash = _.compact(_.map(params, (v, k) -> if v then "#{encodeURIComponent(k)}=#{encodeURIComponent(v)}" else '')).join('&')
		$sce.trustAsResourceUrl "#{baseUrl}##{hash}"

	updateIframeUrl = (match) ->
		messageService.success $scope.runMsg, 'Enjoy the game!'
		$scope.iframeUrl = ''
		viewData = if match.result && match.result.length > 0 then {display: JSON.stringify match.result} else {streamUrl: makeStreamUrl(), matchId: match.objectId}
		_.delay () -> $scope.iframeUrl = makeIframeUrl $scope.game.viewUrl, viewData

	submit = (ranked, players) ->
		myCode =
			language: 'c'
			code: $scope.code

		return messageService.error 'Missing players for game.' if !ranked && (!players || players.length < 1)

		messageService.success $scope.runMsg, 'Submitting...'
		submitFunc = _.partial matchService.try, $scope.gameId, players, myCode
		submitFunc = _.partial matchService.rank, $scope.gameId, myCode if ranked
		submitFunc (err, match) ->
			return messageService.error $scope.runMsg, 'Compile Error', err.message if err && /^Compile Error:/.test err.message
			return messageService.error $scope.runMsg, err.message if err

			updateIframeUrl match

	$scope.try = () ->
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
			return messageService.error $scope.runMsg, err.message if err

			analyticService.trackPlayers $scope.game, players
			submit false, players

	$scope.rank = () ->
		analyticService.trackGame $scope.game, 'rank'
		submit true

	findGame = (gameId) ->
		parseService.getCache "game-#{$scope.gameId}", (err, game) ->
			return messageService.error $scope.gameMsg, err.message if err

			$scope.game = game
			$scope.iframeUrl = makeIframeUrl game.viewUrl
			$scope.code = game.codeTpl?.c || '// Enter your code here' if !$scope.code
			$scope.bgUrl = $sce.trustAsResourceUrl game.bgUrl if game.bgUrl

			analyticService.trackGame $scope.game, 'load'

	findGame $scope.gameId
