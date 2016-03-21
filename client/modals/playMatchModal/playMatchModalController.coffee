app = angular.module 'aimole'

app.controller 'playMatchModalController', ($scope, $rootScope, $uibModalInstance, messageService, modalService, userService, analyticService, game, playersLocalStorageKey) ->

	$scope.msg = {}

	$scope.pick = (index) ->
		options =
			templateUrl: 'views/selectPlayerModal'
			controller: 'selectPlayerModalController'
			animation: false
			size: 'lg'
			backdrop: false
			resolve:
				game: () -> game

		modalService.openModal options, (err, player) ->
			return messageService.error $scope.msg, err.message if err

			$scope.players[index] = player
			$scope.involveMe = _.filter($scope.players, (player) -> player.type == 'me').length > 0
			localStorage.setItem playersLocalStorageKey, angular.toJson $scope.players

	$scope.run = () ->
		$uibModalInstance.close angular.copy $scope.players

	$scope.signIn = () ->
		analyticService.trackGame game, 'signInOnRun'
		userService.signIn (err, user) ->
			return messageService.error $scope.msg, err.message if err
			$scope.user = user

	$scope.dismiss = () ->
		$uibModalInstance.dismiss 'cancel'

	involveMe = (players) ->
		_.filter($scope.players, (player) -> player.type == 'me').length > 0

	try players = angular.fromJson localStorage.getItem playersLocalStorageKey if playersLocalStorageKey

	defaultPlayer = if game.ai?[0] then _.cloneDeep game.ai[0] else {}
	$scope.players = if players?.length then players else _.fill new Array(game.players), defaultPlayer, 0, game.players
	$scope.involveMe = involveMe $scope.players
