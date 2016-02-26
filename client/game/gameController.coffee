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

				if involveMe
					submitPromise = submissionService.submit $scope.gameObjectId, $scope.code
						.then (submission) ->
							playerId = submission.get('user').get 'id'
							submissionId = submission.get 'id'
							players = _.map players, (p) ->
								return p if p.type != 'me'
								return {
									type: 'human'
									human:
										playerId: playerId
										submissionId: submissionId
								}
							return
				else
					submitPromise = Parse.Promise.as()

				submitPromise
					.then () -> gameService.runGame $scope.gameObjectId, players
					.then (result) ->
						$scope.iframeUrl = $sce.trustAsResourceUrl $scope.game.viewUrl + '#display=' + _.escape JSON.stringify result
					.fail (err) -> messageService.error $scope.gameRunMsg, err.message

	$scope.submit = () ->
		'Not implemented yet.'

	findGame = (gameObjectId) ->
		gameService.findGame gameObjectId
			.then (game) ->
				$scope.game = game
				$scope.iframeUrl = $sce.trustAsResourceUrl game.viewUrl
			.fail (err) -> messageService.error $scope.gameMsg, err.message

	findGame $scope.gameObjectId
