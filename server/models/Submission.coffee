
Parse = require 'parse/node'

module.exports = ($) ->

	submissionSchema =
		userId: {type: String, required: true}
		displayName: {type: String, required: true}
		gameId: {type: String, required: true}
		language: {type: String, default: 'c'}
		code: {type: String, default: 'Missing submission code'}
		matchId: {type: String, default: 'Missing match id'}

	Submission = Parse.Object.extend 'Submission'

	Submission.schema = submissionSchema

	return Submission
