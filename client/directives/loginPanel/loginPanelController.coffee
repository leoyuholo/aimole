app = angular.module 'aimole'

app.controller 'loginPanelController', ($scope, userService, messageService) ->

	$scope.onComplete = _.noop if !_.isFunction $scope.onComplete

	$scope.loginMsg = {}
	$scope.loginForm =
		email: ''
		password: ''

	$scope.signupMsg = {}
	$scope.signupForm =
		email: ''
		password: ''
		confirmPassword: ''

	$scope.login = (email, password) ->
		userService.login email, password
			.then $scope.onComplete
			.fail (err) -> messageService.error $scope.loginMsg, err.message

	$scope.signup = (email, password, confirmPassword) ->
		return messageService.error $scope.signupMsg, 'Confirm password and password do not match.' if password != confirmPassword

		userService.signup email, password
			.then $scope.onComplete
			.fail (err) -> messageService.error $scope.signupMsg, err.message
