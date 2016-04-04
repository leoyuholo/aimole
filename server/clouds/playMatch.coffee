
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'playMatch', (req, res) ->
			res.error 'playMatch is deprecated.'
