app = angular.module 'aimole'

app.controller 'adminController', ($scope, userService) ->

	$scope.user = userService.getUser()
