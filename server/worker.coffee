async = require 'async'

$ = require './globals'

async.series [
	$.run.setup
	$.run.worker
], (err) ->
	return $.logger.log 'error', "error starting up aimole worker #{err.message}" if err
	$.logger.log 'info', "[#{$.app.get('env')}]aimole worker starts working"
