loadGruntTasks = require 'load-grunt-tasks'
loadGruntConfigs = require 'load-grunt-configs'

module.exports = (grunt) ->
	options =
		config:
			src: 'grunttask/*.coffee'

	loadGruntTasks grunt
	grunt.initConfig loadGruntConfigs grunt, options

	grunt.registerTask 'lint', ['coffeelint:all']
	grunt.registerTask 'test', ['mochaTest:all']

	grunt.registerTask 'dev', ['jade:dev', 'replace:dev', 'concurrent:dev']
	grunt.registerTask 'dev:test', ['watch:test']

	grunt.registerTask 'travis', ['lint', 'test']

	grunt.registerTask 'default', ['dev']
