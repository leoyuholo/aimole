
async = require 'async'

$ = require './globals'

async.series [
	$.run.setups
	$.run.server
], (err) ->
	return console.log 'Error starting up AI mole', err if err
	console.log 'AI mole listen on port', $.config.port
