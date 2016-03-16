
Parse = require 'parse/node'

module.exports = ($) ->

	cacheSchema =
		key: {type: String, required: true}
		value: {type: String, default: '{}'}
		count: {type: Number, default: 0}

	return Parse.Object.extend 'Cache'
