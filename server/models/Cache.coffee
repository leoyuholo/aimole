
Parse = require 'parse/node'

module.exports = ($) ->

	cacheSchema =
		tags: [{type: String}]
		type: {type: String, default: 'str'}
		str: {type: String, default: ''}
		num: {type: Number, default: 0}
		arr: {type: Array, default: []}
		obj: {type: Object, default: {}}

	Cache = Parse.Object.extend 'Cache'

	Cache.schema = cacheSchema

	Cache.parsePermissions = $.constants.parsePermissions.grantFindOnly

	return Cache
