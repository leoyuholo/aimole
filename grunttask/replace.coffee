
replaceTo = (http, port) ->
	"<script>(function(){document.write('<script src=\"#{http}://' + window.location.hostname + ':#{port}/livereload.js\" type=\"text/javascript\"><\\\/script>')}).call(this);</script></body>"

module.exports = (grunt, options) ->
	http = grunt.option('http') || 'http'
	from = '</body>'
	config =
		dev:
			src: ['public/**/*.html']
			overwrite: true
			replacements: [
				{from: from, to: replaceTo http, grunt.option('livereload') || 35729}
			]

	return config
