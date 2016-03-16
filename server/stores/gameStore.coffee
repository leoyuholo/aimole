
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.findByGithubUrl = (githubUrl, done) ->
		done = _.partial _.defer, done
		new $.Parse.Query($.models.Game)
			.equalTo 'githubUrl', githubUrl
			.first {useMasterKey: true}
			.then (game) -> done null, if game then game.toJSON() else game
			.fail (err) -> done err

	self.upsertByGithubUrl = (githubUrl, newGame, done) ->
		done = _.partial _.defer, done
		new $.Parse.Query($.models.Game)
			.equalTo 'githubUrl', githubUrl
			.first {useMasterKey: true}
			.then (game) ->
				game = game || new $.models.Game()

				gameACL = new $.Parse.ACL()
				gameACL.setPublicReadAccess false
				gameACL.setPublicWriteAccess false
				game.setACL gameACL

				game.save newGame, {useMasterKey: true}
					.then (game) -> done null, if game then game.toJSON() else game
			.fail (err) -> done err

	self.list = (done) ->
		done = _.partial _.defer, done
		new $.Parse.Query($.models.Game)
			.find {useMasterKey: true}
			.then (games) -> done null, _.invokeMap games, 'toJSON'
			.fail (err) -> done err

	return self
