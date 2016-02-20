
module.exports = (grunt, options) ->
	config =
		options:
			compilers: 'coffee:coffee-script/register'
			require: ['coffee-errors']
			timeout: 5000
			clearRequireCache: true
		all:
			src: ['test/**/*Test.coffee']

	return config
