app = angular.module 'aimole'

app.controller 'selectPlayerModalController', ($scope, $rootScope, $uibModalInstance, $uibModal, game) ->

	$scope.ais = game.ai

	$scope.pick = (player) ->
		$uibModalInstance.close player

	$scope.dismiss = () ->
		$uibModalInstance.dismiss 'cancel'
