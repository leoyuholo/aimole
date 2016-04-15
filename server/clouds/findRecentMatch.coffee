
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'findRecentMatch', (req, res) ->
			userId = req.user?.id

			return res.error 'This API is not for anonymous user.' if !userId

			$.stores.matchStore.findLastBySubmitByUserId userId, (err, match) ->
				return res.error err.message if err
				res.success $.models.Match.envelop match
