
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	self.extname =
		c: 'c'
		javascript: 'js'
		python: 'py'
		ruby: 'rb'

	self.names = _.keys self.extname

	return self
