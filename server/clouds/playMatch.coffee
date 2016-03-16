
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'playMatch', (req, res) ->
			matchId = req.params.matchId

			console.log 'playMatch', matchId

			res.success 'Not implemented yet.'
