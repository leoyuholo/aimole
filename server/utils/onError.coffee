
callerId = require 'caller-id'

module.exports = ($) ->
	return (done, err, args...) ->
		if !err.stopPropagation
			$.logger.log 'error', "onError: #{err.message} #{callerId.getDetailedString()} debugInfo: %j", err.debugInfo, {}
			err.stopPropagation = true
		argsArray = Array.prototype.slice.call args
		argsArray.unshift err
		done.apply null, argsArray
