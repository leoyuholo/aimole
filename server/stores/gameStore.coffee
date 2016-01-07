
module.exports = ($) ->
	self = {}

	Game = $.models.Game

	self.list = (done) ->
		Game.find {}, done

	return self
