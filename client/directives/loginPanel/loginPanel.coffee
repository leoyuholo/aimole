app = angular.module 'aimole'

app.directive 'loginPanel', () ->
	return {
		restrict: 'E'
		templateUrl: 'views/loginPanel'
		controller: 'loginPanelController'
		scope:
			onComplete: '='
	}
