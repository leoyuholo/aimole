path = require 'path'

module.exports = (grunt, options) ->
	aimoleConfig = require path.join __dirname, '..', 'configs', 'clientConfig'

	config =
		dev:
			options:
				pretty: true
				data:
					config:
						aimole: aimoleConfig
						env:
							development: true
			files:
				'public/index.html': 'client/index.jade'
		minify:
			options:
				data:
					config:
						aimole: aimoleConfig
						env:
							development: false
			files:
				'public/index.html': 'client/index.jade'

	return config
