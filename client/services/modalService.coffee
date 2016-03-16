app = angular.module 'aimole'

app.service 'modalService', ($rootScope, $uibModal) ->
	self = {}

	self.openModal = (options, done) ->
		modal = $uibModal.open options

		modal.result
			.then (args...) -> done null, args...

		dismissModalListener = $rootScope.$on '$routeChangeStart', () ->
			modal.close() if modal.close
			dismissModalListener()

	return self
