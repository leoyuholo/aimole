app = angular.module 'aimole'

app.directive 'aimoleHeader', () ->
	return {
		restrict: 'A'
		templateUrl: 'views/aimoleHeader'
		controller: 'aimoleHeaderController'
	}
