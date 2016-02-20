app = angular.module 'aimole'

app.controller 'loginController', ($scope, userService, redirectService) ->

	$scope.onComplete = () ->
		redirectService.redirectToHome()

	redirectService.redirectToHome() if userService.getUser()
