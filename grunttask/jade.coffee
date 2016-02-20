
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

	return config
