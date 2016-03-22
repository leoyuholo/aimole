app = angular.module 'aimole'

app.controller 'gamesController', ($scope, $sce, messageService, parseService, analyticService) ->

	$scope.games = []
	$scope.gamesMsg = {}

	$scope.bgUrl = ''

	$scope.users = []
	$scope.userCount = 0

	$scope.listUsers = () ->
		analyticService.trackViewWhoisplaying()

		parseService.run 'whoisplaying', {}, (err, result) ->
			return if err# ignore error
			$scope.userCount = result.userCount
			$scope.users = result.users

	listGames = () ->
		parseService.getCache 'games', (err, games) ->
			return messageService.error $scope.gamesMsg, err.message if err
			$scope.games = games

			$scope.bgUrl = $sce.trustAsResourceUrl games[0].bgUrl if games && games.length > 0 && games[0].bgUrl

	listGames()
