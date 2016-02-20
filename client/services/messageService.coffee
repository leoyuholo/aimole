app = angular.module 'aimole'

app.service 'messageService', ($rootScope) ->
	self = {}

	self.clear = (target) ->
		target = target || $rootScope
		target.successMessage = ''
		target.errorMessage = ''

	self.error = (target, errorMessage) ->
		if _.isString target
			errorMessage = target
			target = $rootScope

		self.clear target
		target.errorMessage = errorMessage

	self.success = (target, successMessage) ->
		if _.isString target
			successMessage = target
			target = $rootScope

		self.clear target
		target.successMessage = successMessage

	return self
