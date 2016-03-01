fs = require 'fs'

_ = require 'lodash'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'runGame', (req, res) ->
			gameInfo = req.params.gameInfo
			gameInfo.user =
				id: req.user.get 'id'
				email: req.user.get 'email'
				username: req.user.get 'username'
			$.services.submissionService.run gameInfo, (err, result) ->
				return res.error err.message if err

				gameInfo.result = result

				(new $.models.GameResult()).save gameInfo
					.then (gameResult) ->
						if gameInfo.submissionId
							submissionPromise = (new Parse.Query($.models.Submission)).get gameInfo.submissionId
								.then (submission) ->
									submission.set 'gameResult', gameResult
									submission.save()
						else
							submissionPromise = Parse.Promise.as()
						submissionPromise.then () -> res.success _.map _.map(_.filter(result, (r) -> r.type == 'action'), 'data'), 'display'
					.fail (err) -> res.error err

		Parse.Cloud.beforeSave 'Game', (req, res) ->
			url = req.object.get 'url'
			return res.error('Invalid url.') if !url || !_.isString url

			if req.object.isNew()
				$.logger.info "installing game with url [#{url}]"
			else
				$.logger.info "updating game with url [#{url}]"

			$.services.gameService.install url, (err, gameConfig) ->
				return res.error err.message if err

				(new $.models.GameConfig()).save gameConfig
					.then (gameConfig) ->
						req.object.set 'name', gameConfig.get 'name'
						req.object.set 'description', gameConfig.get 'description'
						req.object.set 'author', gameConfig.get 'author'
						req.object.set 'version', gameConfig.get 'version'
						req.object.set 'players', gameConfig.get 'players'
						req.object.set 'ai', _.map gameConfig.get('ai'), _.partialRight _.pick, ['name', 'type']
						req.object.set 'viewUrl', gameConfig.get 'viewUrl'
						req.object.set 'gameConfig', gameConfig

						res.success()
					.fail (err) -> res.error err.message
