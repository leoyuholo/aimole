
async = require 'async'
_ = require 'lodash'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'playMatch', (req, res) ->
			matchId = req.params.matchId

			return res.error 'Missing match id.' if !matchId

			$.stores.matchStore.findById matchId, (err, match) ->
				return res.error err.message if err
				res.success $.models.Match.envelop match
