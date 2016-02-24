app = angular.module 'aimole'

app.controller 'aimoleEditorController', ($scope) ->

	editor = {}

	saveCode = () ->
		localStorage.setItem $scope.localStorageKey, editor.getValue() if $scope.localStorageKey

	saveCodeThrottled = _.throttle saveCode, 500

	aceLoaded = (_editor) ->
		editor = _editor

		editor.$blockScrolling = Infinity
		editor.setAutoScrollEditorIntoView true

		# editor.setOptions
		# 	minLines: $scope.aceOptions?.minLines || 20
		# 	maxLines: $scope.aceOptions?.maxLines || 80

		editor.commands.addCommand
			name: 'save'
			bindKey:
				win: 'Ctrl-S'
				mac: 'Command-S'
			exec: saveCode

		editor.setReadOnly $scope.readOnly

		editor.setValue localStorage.getItem($scope.localStorageKey) || '' if !$scope.ngModel && !editor.getValue() && $scope.localStorageKey

	setAceOptions = () ->
		defaultOptions =
			onLoad: aceLoaded
			onChange: () ->
				$scope.ngModel = editor.getValue()
				saveCodeThrottled()

		$scope.aceOptions = _.defaults _.cloneDeep($scope.editorOptions) || {}, defaultOptions

	setLanguage = () ->
		editor.getSession().setMode "ace/mode/#{if $scope.language == 'c' then 'c_cpp' else $scope.language}" if $scope.language

	$scope.$watch 'editorOptions', setAceOptions
	$scope.$watch 'language', setLanguage

	setAceOptions()
