
module.exports = (grunt, options) ->
	config =
		options:
			compilers: 'coffee:coffee-script/register'
			require: ['coffee-errors']
			timeout: 5000
			clearRequireCache: true
		all:
			src: grunt.option('target') || ['test/server/**/*Test.coffee']

	return config
