
shortid = require 'shortid'

module.exports = ($) ->
	self = {}

	self.generateId = () ->
		shortid.generate()

	return self
