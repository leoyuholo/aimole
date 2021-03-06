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
			onChange: '='
			editorOptions: '='
		controller: 'aimoleEditorController'
	}
