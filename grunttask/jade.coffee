
module.exports = (grunt, options) ->
	config =
		dev:
			options:
				pretty: true
				data:
					config:
						env:
							development: true
			files:
				'public/index.html': 'client/index.jade'
		minify:
			options:
				data:
					config:
						env:
							development: false
			files:
				'public/index.html': 'client/index.jade'

	return config
