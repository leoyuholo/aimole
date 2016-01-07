
_ = require 'lodash'

module.exports = ($) ->
	return (err, req, res, done) ->
		if err
			# console.log err.stack
			errMsg = ''
			if err.errors
				_.each err.errors, (e) ->
					errMsg += "\n#{e.message}"
			res.json
				success: false
				msg: errMsg || err.message
