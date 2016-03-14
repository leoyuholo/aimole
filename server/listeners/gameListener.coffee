
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.gameUpdated = () ->
		done = _.noop
		$.stores.gameStore.list (err, games) ->
			return return $.utils.onError done, err if err
			$.stores.cacheStore.upsert 'games', JSON.stringify(games), (err) ->
				return $.utils.onError done, err if err
	$.emitter.on 'gameUpdated', self.gameUpdated

	return self
