app = angular.module 'aimole'

app.controller 'gameController', ($scope, $rootScope, $routeParams, $sce, $timeout, messageService, parseService, modalService, matchService, analyticService) ->

	$scope.gameId = $routeParams.gameId
	$scope.matchId = $routeParams.matchId

	$scope.game = {}
	$scope.gameMsg = {}
	$scope.runMsg = {}
	$scope.iframeUrl = ''
	$scope.bgUrl = ''
	$scope.languages = ['C', 'Python', 'Javascript', 'Ruby']

	$scope.language = 'C'
	$scope.code = ''
	$scope.codeTpl = ''
	$scope.codeLocalStorageKey = "game/#{$scope.gameId}"
	$scope.languageLocalStorageKey = "language/#{$scope.gameId}"
	$scope.codeAceOptions =
		maxLines: Infinity
	timer = Date.now()
	$scope.editorOnChange = _.throttle ( () -> analyticService.trackActiveEditing $scope.game, timer), 10 * 60 * 1000

	playersLocalStorageKey = "players/#{$scope.gameId}"

	$scope.setLanguage = (lang) ->
		$scope.language = lang
		localStorage.setItem $scope.languageLocalStorageKey, lang

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
			return messageService.error $scope.runMsg, err.message if err
			return messageService.clear $scope.runMsg if !matchId
			matchService.playMatch matchId, (err, match) ->
				return messageService.error $scope.runMsg, err.message if err
				updateIframeUrl match

	watchRecentMatch = () ->
		analyticService.trackGame $scope.game, 'watchRecentMatch'

		modalOptions =
			templateUrl: 'views/watchRecentMatchModal'
			controller: 'watchRecentMatchModalController'
			animation: false
			size: 'md'
			resolve:
				game: () -> $scope.game

		modalService.openModal modalOptions, (err, matchId) ->
			return messageService.error $scope.runMsg, err.message if err
			return messageService.clear $scope.runMsg if !matchId
			matchService.playMatch matchId, (err, match) ->
				return messageService.error $scope.runMsg, err.message if err
				updateIframeUrl match

	makeStreamUrl = () ->
		"#{window.location.origin}/match"

	makeIframeUrl = (baseUrl, params) ->
		baseUrl = if window.location.protocol == 'https:' then baseUrl.replace /^http:/, 'https:' else baseUrl.replace /^https:/, 'http:'
		hash = _.compact(_.map(params, (v, k) -> if v then "#{encodeURIComponent(k)}=#{encodeURIComponent(v)}" else '')).join('&')
		$sce.trustAsResourceUrl "#{baseUrl}##{hash}"

	updateIframeUrl = (match) ->
		messageService.success $scope.runMsg, 'Enjoy the game!'
		$scope.iframeUrl = ''
		viewData = if match.state == 'evaluated' then {display: JSON.stringify match.result} else {streamUrl: makeStreamUrl(), matchId: match.objectId}
		$timeout () -> $scope.iframeUrl = makeIframeUrl $scope.game.viewUrl, viewData

	submit = (ranked, players) ->
		myCode =
			language: $scope.language.toLowerCase()
			code: $scope.code

		return messageService.error 'Missing players for game.' if !ranked && (!players || players.length < 1)

		messageService.success $scope.runMsg, 'Submitting...'
		submitFunc = _.partial matchService.try, $scope.gameId, players, myCode
		submitFunc = _.partial matchService.rank, $scope.gameId, myCode if ranked
		submitFunc (err, match) ->
			return messageService.error $scope.runMsg, 'Compile Error', err.message if err && /^Compile Error:/.test err.message
			return watchRecentMatch() if err && _.startsWith err.message, 'You have an unfinished match.'
			return messageService.success $scope.runMsg, err.message if err && _.startsWith err.message, 'Congraduations, you\'re No.1 in this game!'
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
			updateIframeUrl {objectId: $scope.matchId} if $scope.matchId
			$scope.language = localStorage.getItem($scope.languageLocalStorageKey) || 'C'
			$scope.code = game.codeTpl?[$scope.language?.toLowerCase()] || '// Enter your code here' if !$scope.code
			$scope.bgUrl = $sce.trustAsResourceUrl game.bgUrl if game.bgUrl

			analyticService.trackGame $scope.game, 'load'

	findGame $scope.gameId
