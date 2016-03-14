
Parse = require 'parse/node'

module.exports = ($) ->

	# cacheSchema =
	# 	key: {type: String, required: true}
	# 	value: {type: String, default: '{}'}

	return Parse.Object.extend 'Cache'
