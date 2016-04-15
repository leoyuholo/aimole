app = angular.module 'aimole'

app.controller 'watchRecentMatchModalController', ($scope, $rootScope, $uibModalInstance, game, messageService, parseService) ->

	$scope.msg = {}
	$scope.game = game
	$scope.recentMatch = {}

	$scope.dismiss = () ->
		$uibModalInstance.close()

	$scope.watch = () ->
		$uibModalInstance.close $scope.recentMatch.objectId

	findRecentMatch = () ->
		parseService.run 'findRecentMatch', {}, (err, match) ->
			return messageService.error $scope.msg, err.message if err
			$scope.recentMatch = match

	findRecentMatch()
