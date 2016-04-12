app = angular.module 'aimole'

app.service 'matchService', (parseService, userService) ->
	self = {}

	submit = (gameId, myCode, ranked, players, done) ->
		submission =
			gameId: gameId
			language: myCode.language
			code: myCode.code
			ranked: ranked
			players: players

		parseService.run 'submit', submission, done

	self.playMatch = (matchId, done) ->
		parseService.run 'playMatch', {matchId: matchId}, done

	self.try = (gameId, players, myCode, done) ->
		involveMe = _.filter(players, (p) -> p.type == 'me').length > 0
		return parseService.run 'viewMatch', {gameId: gameId, players: players}, done if !involveMe
		submit gameId, myCode, false, players, done

	self.rank = (gameId, myCode, done) ->
		submit gameId, myCode, true, [], done

	return self
