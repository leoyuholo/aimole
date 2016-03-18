app = angular.module 'aimole'

app.service 'matchService', (parseService, userService) ->
	self = {}

	self.playMatch = (matchId, done) ->
		parseService.run 'playMatch', {matchId: matchId}, done

	self.newMatch = (gameId, players, myCode, done) ->
		involveMe = _.filter(players, (p) -> p.type == 'me').length > 0

		return parseService.run 'newMatch', {gameId: gameId, players: players}, done if !involveMe

		parseService.run 'submit', {gameId: gameId, players: players, language: myCode.language, code: myCode.code}, done

	return self
