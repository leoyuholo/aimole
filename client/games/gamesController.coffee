app = angular.module 'aimole'

app.controller 'gamesController', ($scope, messageService, parseService) ->

	$scope.games = []
	$scope.gamesMsg = {}

	$scope.users = []
	$scope.userCount = 0

	getUserCount = () ->
		parseService.getCount 'userCount', (err, userCount) ->
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

	listGames()
	listUsers()
	getUserCount()
