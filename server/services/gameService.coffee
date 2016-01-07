
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.list = (done) ->
		$.stores.gameStore.list (err, games) ->
			return $.utils.onError done, err if err

			done null, _.map games, $.models.Game.envelop

	return self
