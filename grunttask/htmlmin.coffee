
module.exports = (grunt, options) ->
	opts =
		removeComments: true
		collapseWhitespace: true
		conservativeCollapse: true
		minifyJS:
			mangle: false
		minifyCSS: true

	config =
		html:
			options: opts
			files:
				'public/index.html': 'public/index.html'

	return config
