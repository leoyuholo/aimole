$ = require './globals'

$.app.listen $.config.port, () ->
	console.log "server listening on port #{$.config.port}"
