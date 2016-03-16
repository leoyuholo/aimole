
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.define 'submit', (req, res) ->
			gameId = req.params.gameId
			language = req.params.language
			code = req.params.code

			console.log 'submit', gameId, language, code

			res.success 'Not implemented yet.'
