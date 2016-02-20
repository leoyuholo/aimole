app = angular.module 'aimole'

app.controller 'loginModalController', ($scope, $uibModalInstance) ->

	$scope.dismiss = () ->
		$uibModalInstance.close()

