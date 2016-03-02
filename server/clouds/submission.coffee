
_ = require 'lodash'

module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.beforeSave 'Submission', (req, res) ->
			code = req.object.get 'code'
			language = req.object.get 'language'

			submissionInfo =
				language: language
				code: code

			$.utils.amqp.rpcClient $.config.rabbitmq.queues.submission, JSON.stringify(submissionInfo), (err, result) ->
				try
					result = JSON.parse result
				catch err
					return res.error err.message
				return res.error "Compile Error: #{result.compileErrorMessage}" if result && result.errorMessage == 'Compile Error'
				return res.error result.errorMessage if result && result.errorMessage
				return res.error err.message if err

				res.success()
