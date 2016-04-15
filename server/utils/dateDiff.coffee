
_ = require 'lodash'
moment = require 'moment'

module.exports = ($) ->
	return (date, precision) ->
		moment(date).diff moment(), precision || 'minutes'

