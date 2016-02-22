app = angular.module 'aimole'

app.controller 'aimoleHeaderController', ($scope, $rootScope, $location, $uibModal, userService, redirectService) ->

	$scope.showSignIn = $location.path() != '/login'

	$scope.user = userService.getUser()

	loginModal = {}

	$scope.logout = () ->
		userService.logout()
			.then redirectService.redirectToHome

	$scope.openLoginModal = () ->
		options =
			templateUrl: 'views/loginModal'
			controller: 'loginModalController'
			animation: false
			size: 'lg'
			keyboard: false

		loginModal = $uibModal.open options

		loginModal.result.then () ->
			$scope.user = userService.getUser()

	$rootScope.$on '$routeChangeStart', () ->
		loginModal.close() if loginModal.close
