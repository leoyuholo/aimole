app = angular.module 'aimole'

app.directive 'aimoleEditor', () ->
	return {
		restrict: 'E'
		templateUrl: 'views/aimoleEditor'
		scope:
			localStorageKey: '='
			language: '='
			readOnly: '='
			ngModel: '='
			editorOptions: '='
		controller: 'aimoleEditorController'
	}
