app = angular.module 'aimole'

app.service 'messageService', ($rootScope) ->
	self = {}

	self.clear = (target) ->
		target = target || $rootScope
		target.successMessage = ''
		target.warningMessage = ''
		target.errorMessage = ''
		target.details = ''

	self.error = (target, errorMessage, details) ->
		if _.isString target
			errorMessage = target
			target = $rootScope

		self.clear target
		target.errorMessage = errorMessage
		target.details = details

	self.success = (target, successMessage, details) ->
		if _.isString target
			successMessage = target
			target = $rootScope

		self.clear target
		target.successMessage = successMessage
		target.details = details

	self.warning = (target, warningMessage, details) ->
		if _.isString target
			successMessage = target
			target = $rootScope

		self.clear target
		target.warningMessage = warningMessage
		target.details = details

	return self
