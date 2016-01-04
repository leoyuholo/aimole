
module.exports = (grunt, options) ->
	config =
		options:
			configFile: 'coffeelint.json'
		all:
			src: grunt.option('target') || ['**/*.coffee', '!node_modules/**']

	return config
