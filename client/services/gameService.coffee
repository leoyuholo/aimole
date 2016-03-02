app = angular.module 'aimole'

app.service 'gameService', () ->
	self = {}

	Game = Parse.Object.extend 'Game'
	GameConfig = Parse.Object.extend 'GameConfig'

	self.runGame = (gameObjectId, players, submissionId) ->
		gameInfo =
			gameObjectId: gameObjectId
			players: players

		gameInfo.submissionId = submissionId if submissionId

		Parse.Cloud.run 'runGame', {gameInfo: gameInfo}

	self.findGame = (gameObjectId) ->
		query = new Parse.Query(Game)
		query.get gameObjectId
			.then (game) -> game?.toJSON()

	self.listGames = () ->
		query = new Parse.Query(Game)
		query.find()
			.then (games) -> _.invokeMap games, 'toJSON'

	self.addGame = (url) ->
		return Parse.Promise.error new Error('Not a git url.') if !/.git$/.test url

		query = new Parse.Query(Game)
		query.equalTo 'url', url
			.first()
			.then (game) ->
				if !game
					gameACL = new Parse.ACL()
					gameACL.setRoleWriteAccess 'Administrator', true
					gameACL.setPublicReadAccess true
					game = new Game()
					game.set 'url', url
					game.set 'name', ''
					game.set 'description', ''
					game.set 'author', ''
					game.set 'version', ''
					game.set 'players', 0
					game.set 'ai', []
					game.set 'viewUrl', 'string'
					game.set 'gameConfig', new GameConfig()

					game.setACL gameACL

				game.save()

	return self
