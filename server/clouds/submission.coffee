
_ = require 'lodash'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.beforeSave 'Submission', (req, res) ->
			code = req.object.get 'code'
			language = req.object.get 'language'

			# checkout compile error
			# res.error("Compile Error: #{err.message}")

			res.success()
