app = angular.module 'aimole'

app.controller 'gamesController', ($scope, $sce, messageService, parseService) ->

	$scope.games = []
	$scope.gamesMsg = {}

	$scope.bgUrl = ''

	$scope.users = []
	$scope.userCount = 0

	getUserCount = () ->
		parseService.getCache 'userCount', (err, userCount) ->
			# ignore error
			$scope.userCount = userCount

	listUsers = () ->
		parseService.getCache 'users', (err, users) ->
			# ignore error
			$scope.users = users

	listGames = () ->
		parseService.getCache 'games', (err, games) ->
			return messageService.error gamesMsg, err.message if err
			$scope.games = games

			$scope.bgUrl = $sce.trustAsResourceUrl games[0].bgUrl if games && games.length > 0 && games[0].bgUrl

	listGames()
	listUsers()
	getUserCount()
