fs = require 'fs'

_ = require 'lodash'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.beforeSave 'Game', (req, res) ->
			url = req.object.get 'url'
			return res.error('Invalid url.') if !url || !_.isString url

			if req.object.isNew()
				$.logger.info "installing game with url [#{url}]"
			else
				$.logger.info "updating game with url [#{url}]"

			$.services.gameService.install url, (err, installInfo) ->
				return res.error err.message if err

				fs.readFile installInfo.tarFilePath, (err, data) ->
					return res.error err.message if err

					gameFile = new Parse.File('gameFile.tar.gz', Array.prototype.slice.call new Buffer(data), 0)
					gameFile.save()
						.then () ->
							req.object.set 'name', installInfo.gameConfig.name
							req.object.set 'description', installInfo.gameConfig.description
							req.object.set 'author', installInfo.gameConfig.author
							req.object.set 'version', installInfo.gameConfig.version
							req.object.set 'gameConfig', installInfo.gameConfig
							req.object.set 'gameFile', gameFile

							res.success()
						.fail (err) -> res.error err.message
