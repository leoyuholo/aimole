loadGruntTasks = require 'load-grunt-tasks'
loadGruntConfigs = require 'load-grunt-configs'

module.exports = (grunt) ->
	options =
		config:
			src: 'grunttask/*.coffee'

	loadGruntTasks grunt
	grunt.initConfig loadGruntConfigs grunt, options

	grunt.registerTask 'dev', ['env:dev', 'jade:dev', 'concurrent:dev']

	grunt.registerTask 'lint', ['coffeelint:all']

	grunt.registerTask 'test', ['env:test', 'mochaTest:all']
	grunt.registerTask 'test:watch', ['env:test', 'watch:test']

	grunt.registerTask 'html', ['curl-dir', 'jade:minify', 'htmlmin:html']

	grunt.registerTask 'default', ['lint', 'test']
