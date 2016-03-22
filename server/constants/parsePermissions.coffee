
module.exports = ($) ->
	self= {}

	self.grantNone =
		'find': {}
		'get': {}
		'create': {}
		'update': {}
		'delete': {}
		'addField': {}

	self.grantFindOnly =
		'find': {'*': true}
		'get': {}
		'create': {}
		'update': {}
		'delete': {}
		'addField': {}

	return self
