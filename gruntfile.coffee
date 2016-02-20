loadGruntTasks = require 'load-grunt-tasks'
loadGruntConfigs = require 'load-grunt-configs'

module.exports = (grunt) ->
	options =
		config:
			src: 'grunttask/*.coffee'

	loadGruntTasks grunt
	grunt.initConfig loadGruntConfigs grunt, options

	grunt.registerTask 'dev', ['jade:dev', 'concurrent:dev']

	grunt.registerTask 'lint', ['coffeelint:all']

	grunt.registerTask 'test', ['mochaTest:all']

	grunt.registerTask 'default', ['lint', 'test']
