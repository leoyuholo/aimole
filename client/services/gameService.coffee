app = angular.module 'aimole'

app.service 'gameService', () ->
	self = {}

	self.addGame = (url) ->
		return Parse.Promise.error new Error('Not a git url.') if !/.git$/.test url

		Game = Parse.Object.extend 'Game'

		game = new Game()
		game.set 'url', url

		game.save()

	return self
