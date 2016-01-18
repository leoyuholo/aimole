# require modules
fse = require 'fs-extra'
path = require 'path'

_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.list = (done) ->
		$.stores.gameStore.list (err, games) ->
			return $.utils.onError done, err if err

			done null, _.map games, $.models.Game.envelop

	self.submit = (player1, done) ->
		fse.readFile path.join($.gameDir, 'tictactoe', 'easyplayer.c'), (err, player2) ->
			return $.utils.onError done, err if err
			fse.readFile path.join($.gameDir, 'tictactoe', 'verdict.py'), (err, verdict) ->
				return $.utils.onError done, err if err
				$.services.sandboxService.run player1, player2, verdict, (err, gameResult) ->
					return $.utils.onError done, err if err
					done null, gameResult

	return self
