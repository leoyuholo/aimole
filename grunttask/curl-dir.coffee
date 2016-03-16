path = require 'path'

_ = require 'lodash'

module.exports = (grunt, options) ->
	cdnUrls = require '../cdnfiles'

	libDir = path.join __dirname, '..', 'public', 'libs'

	config =
		all:
			src: cdnUrls
			dest: libDir
			router: (url) ->
				url.replace('https://ajax.googleapis.com/', '')
					.replace('https://cdn.rawgit.com/', '')
					.replace('https://cdnjs.cloudflare.com/', '')
					.replace('https://www.parsecdn.com/', '')

	return config
