
module.exports = (grunt, options) ->
	config =
		options:
			configFile: 'coffeelint.json'
		all:
			src: ['**/*.coffee', '!node_modules/**']

	return config
