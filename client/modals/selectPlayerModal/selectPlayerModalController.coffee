app = angular.module 'aimole'

app.controller 'selectPlayerModalController', ($scope, $rootScope, $uibModalInstance, game) ->

	$scope.ais = game.ai

	$scope.pick = (player) ->
		$uibModalInstance.close angular.copy player

	$scope.dismiss = () ->
		$uibModalInstance.dismiss 'cancel'
