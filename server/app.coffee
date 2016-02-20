
$ = require './globals'

$.run.server (err) ->
	return $.logger.error "error starting up aimole #{err.message}" if err
	$.logger.info "[#{$.app.get 'env'}] aimole listen on port #{$.config.port}"
