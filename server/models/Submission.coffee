
_ = require 'lodash'
Parse = require 'parse/node'

module.exports = ($) ->

	# submissionSchema =
	# 	userId: {type: String, required: true}
	# 	displayName: {type: String, required: true}
	# 	gameId: {type: String, required: true}
	# 	language: {type: String, default: 'c'}
	# 	code: {type: String, default: 'Missing submission code'}
	# 	matchId: {type: String, default: 'Missing match id'}

	return Parse.Object.extend 'Submission'
