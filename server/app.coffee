async = require 'async'

$ = require('./globals') {}

async.series [
	$.run.setup
	$.run.server
	$.run.parseSchemaSetup
	$.run.analysisWorker
], (err) ->
	return $.logger.log 'error', "error starting up aimole web server #{err.message}" if err
	$.logger.log 'info', "[#{$.app.get('env')}]aimole web server is listening on port #{$.config.port}"
