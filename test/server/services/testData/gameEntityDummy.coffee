
process.stdin.on 'data', (data) ->
	if data.toString() == 'error\n'
		process.stderr.write 'error message: error\n'
	else if data.toString() == 'exit\n'
		process.exit 1
	else
		process.stdout.write data
