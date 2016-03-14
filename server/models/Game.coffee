
Parse = require 'parse/node'

module.exports = ($) ->

	# gameSchema =
	# 	githubUrl: {type: String, required: true}
	# 	name: {type: String, required: true}
	# 	description: {type: String, default: ''}
	# 	author: {type: String, default: ''}
	# 	version: {type: String, default: '0.0.0'}
	# 	viewUrl: {type: String, default: ''}
	# 	players: {type: Number, default: 1}
	# 	ai: [
	# 		name: {type: String, default: 'Anonymous AI'}
	# 		language: {type: String, enum: languages, default: 'c'}
	# 		code: {type: String, default: 'Missing ai code'}
	# 		file: {type: String, default: ''}
	# 		type: {type: String, default: 'ai'}
	# 	]
	# 	verdict:
	# 		language: {type: String, enum: languages, default: 'c'}
	# 		code: {type: String, default: 'Missing verdict code'}
	# 		file: {type: String, default: ''}

	return Parse.Object.extend 'Game'
