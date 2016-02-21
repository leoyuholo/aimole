app = angular.module 'aimole'

app.service 'gameService', () ->
	self = {}

	Game = Parse.Object.extend 'Game'

	self.addGame = (url) ->
		return Parse.Promise.error new Error('Not a git url.') if !/.git$/.test url

		query = new Parse.Query(Game)
		query.equalTo 'url', url
			.first()
			.then (game) ->
				return game if game
				game = new Game()
				game.set 'url', url
			.then (game) ->
				gameACL = new Parse.ACL()
				gameACL.setRoleWriteAccess 'Administrator', true
				gameACL.setPublicReadAccess true
				game.setACL gameACL
				game.save()

	return self
