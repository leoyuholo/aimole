app = angular.module 'aimole'

app.service 'redirectService', ($location, $rootScope) ->
	self = {}

	self.redirectToHome = () ->
		$location.path '/'

	self.redirectTo = () ->
		$location.path '/' + Array.prototype.join.call arguments, '/'

	return self
