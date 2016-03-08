app = angular.module 'aimole'

app.controller 'gameController', ($scope, $rootScope, $routeParams, $sce, $uibModal, submissionService, messageService, gameService) ->

	$scope.gameObjectId = $routeParams.gameObjectId

	$scope.game = {}
	$scope.gameMsg = {}
	$scope.gameRunMsg = {}
	$scope.iframeUrl = ''

	$scope.code = ''
	$scope.codeLocalStorageKey = "game/#{$scope.gameObjectId}"
	$scope.codeAceOptions =
		maxLines: Infinity

	playersLocalStorageKey = "players/#{$scope.gameObjectId}"

	$scope.run = () ->
		$scope.compileError = ''
		messageService.clear $scope.gameRunMsg
		options =
			templateUrl: 'views/runGameModal'
			controller: 'runGameModalController'
			animation: false
			size: 'md'
			backdrop: false
			resolve:
				game: () -> $scope.game
				playersLocalStorageKey: () -> playersLocalStorageKey

		runGameModal = $uibModal.open options

		dismissModalListener = $rootScope.$on '$routeChangeStart', () ->
			runGameModal.close() if runGameModal.close
			dismissModalListener()

		runGameModal.result
			.then (players) ->
				involveMe = _.filter(players, (p) -> p.type == 'me').length > 0
				submissionId = ''

				if involveMe
					submitPromise = submissionService.submit $scope.gameObjectId, $scope.code
						.then (submission) ->
							playerId = Parse.User.current().id
							submissionId = submission.id
							players = _.map players, (p) ->
								return p if p.type != 'me'
								return {
									type: 'human'
									playerId: playerId
									submissionId: submissionId
								}
							return
				else
					submitPromise = Parse.Promise.as()

				submitPromise
					.then () -> gameService.runGame $scope.gameObjectId, players, submissionId
					.then (result) ->
						return messageService.error $scope.gameRunMsg, result.errorMessage if result.errorMessage
						$scope.iframeUrl = $sce.trustAsResourceUrl $scope.game.viewUrl + '#display=' + encodeURIComponent JSON.stringify result
					.fail (err) ->
						return $scope.compileError = err.message if /^Compile Error/.test err.message
						messageService.error $scope.gameRunMsg, err.message

	$scope.submit = () ->
		'Not implemented yet.'

	findGame = (gameObjectId) ->
		gameService.findGame gameObjectId
			.then (game) ->
				$scope.game = game
				$scope.iframeUrl = $sce.trustAsResourceUrl game.viewUrl
			.fail (err) -> messageService.error $scope.gameMsg, err.message

	findGame $scope.gameObjectId
