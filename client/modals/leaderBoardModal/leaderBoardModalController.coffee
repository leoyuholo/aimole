app = angular.module 'aimole'

app.controller 'leaderBoardModalController', ($scope, $uibModalInstance, parseService, game) ->

	$scope.msg = {}
	$scope.profiles = []
	$scope.game = game

	$scope.dismiss = () ->
		$uibModalInstance.dismiss 'cancel'

	$scope.replay = (matchId) ->
		$uibModalInstance.close matchId

	$scope.makeMatchDescription = (submission) ->
		return '' if !submission
		_.map(submission.players, 'name').join ' vs. '

	loadLeaderBoard = () ->
		parseService.getCache "leaderboard-#{game.objectId}", (err, profiles) ->
			return messageService.error $scope.msg, err.message if err
			profiles = _.map profiles, (p) ->
				p.submissions = [_.last p.submissions]
				return p
			$scope.profiles = profiles

	loadLeaderBoard()
