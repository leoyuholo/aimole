
Parse = require 'parse/node'

module.exports = ($) ->

	# cacheSchema =
	# 	tags: [String]
	# 	type: {type: String, default: 'str'}
	# 	str: {type: String, default: ''}
	# 	num: {type: Number, default: 0}
	# 	arr: {type: Array, default: []}
	# 	obj: {type: Object, default: {}}

	return Parse.Object.extend 'Cache'
