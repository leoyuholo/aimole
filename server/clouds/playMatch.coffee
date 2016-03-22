
async = require 'async'
_ = require 'lodash'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'playMatch', (req, res) ->
			userId = req.user?.id || 'anonymouse'
			displayName = req.user?.get?('displayName') || 'Anonymouse'
			matchId = req.params.matchId

			return res.error 'Missing match id.' if !matchId

			async.waterfall [
				_.partial $.stores.matchStore.findById, matchId
				(match, done) ->
					return done null, match if match?.status == 'evaluated'
					async.waterfall [
						_.partial $.services.matchService.play, matchId
						_.partial $.stores.matchStore.finalizeResult, matchId
					], done
			], (err, match) ->
				return res.error err.message if err
				res.success $.models.Match.envelop match
