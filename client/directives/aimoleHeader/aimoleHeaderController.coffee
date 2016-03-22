app = angular.module 'aimole'

app.controller 'aimoleHeaderController', ($scope, $rootScope, messageService, userService, redirectService) ->

	$scope.msg = {}
	$scope.user = $rootScope.user
	$rootScope.$watch 'user', () ->
		$scope.user = $rootScope.user

	$scope.logout = () ->
		userService.logout()

	$scope.signIn = () ->
		userService.signIn (err, user) ->
			return messageService.error $scope.msg, err.message if err
			$scope.user = user
