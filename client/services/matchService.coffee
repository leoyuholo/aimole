app = angular.module 'aimole'

app.service 'matchService', (parseService, userService) ->
	self = {}

	self.playMatch = (matchId, done) ->
		parseService.run 'playMatch', {matchId: matchId}, done

	self.newMatch = (gameId, players, myCode, done) ->
		involveMe = _.filter(players, (p) -> p.type == 'me').length > 0

		return parseService.run 'newMatch', {gameId: gameId, players: players}, done if !involveMe

		parseService.run 'submit', {gameId: gameId, language: myCode.language, code: myCode.code}, (err, submissionId) ->
			return done err if err

			submission =
				submissionId: submissionId
				userId: userService.getUser().objectId

			match =
				gameId: gameId
				players: _.map players, (player) -> if player.type == 'me' then submission else player

			parseService.run 'newMatch', match, done

	return self
