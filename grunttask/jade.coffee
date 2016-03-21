path = require 'path'

module.exports = (grunt, options) ->
	appConfig = require path.join __dirname, '..', 'configs', 'config'

	config =
		dev:
			options:
				pretty: true
				data:
					config: appConfig
			files:
				'public/index.html': 'client/index.jade'
		minify:
			options:
				data:
					config: appConfig
			files:
				'public/index.html': 'client/index.jade'

	return config
