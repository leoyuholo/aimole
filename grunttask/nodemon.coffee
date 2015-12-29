fs = require 'fs'
path = require 'path'

module.exports = (grunt, options) ->
	config =
		dev:
			script: 'server/app.coffee'
			options:
				execMap:
					coffee: 'node_modules/.bin/coffee'
				watch: ['server/', 'configs/']
				callback: (nodemon) ->
					nodemon.on 'restart', () ->
						setTimeout ( () ->
							fs.writeFileSync path.join(__dirname, '..', 'public', '.rebooted'), 'rebooted'
						), 5000

	return config
