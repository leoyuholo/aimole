app = angular.module 'aimole'

app.controller 'runGameModalController', ($scope, $rootScope, $uibModalInstance, $uibModal, game, playersLocalStorageKey) ->

	players = localStorage.getItem playersLocalStorageKey if playersLocalStorageKey
	try
		players = JSON.parse players if players
	catch err
		console.log err

	$scope.players = if players?.length then players else _.fill new Array(game.players), {}, 0, game.players

	$scope.pick = (index) ->
		options =
			templateUrl: 'views/selectPlayerModal'
			controller: 'selectPlayerModalController'
			animation: false
			size: 'lg'
			backdrop: false
			resolve:
				game: () -> game

		selectPlayerModal = $uibModal.open options

		dismissModalListener = $rootScope.$on '$routeChangeStart', () ->
			selectPlayerModal.close() if selectPlayerModal.close
			dismissModalListener()

		selectPlayerModal.result
			.then (player) ->
				$scope.players[index] = player

	$scope.run = () ->
		localStorage.setItem playersLocalStorageKey, JSON.stringify $scope.players
		$uibModalInstance.close $scope.players

	$scope.dismiss = () ->
		$uibModalInstance.dismiss 'cancel'
