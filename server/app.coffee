
async = require 'async'

$ = require './globals'

async.series [
	$.run.setups
	$.run.server
], (err) ->
	return console.log 'error starting up codeSubmit admin', err if err
	console.log 'codeSubmit admin listen on port', $.config.port
