loadGruntTasks = require 'load-grunt-tasks'
loadGruntConfigs = require 'load-grunt-configs'

module.exports = (grunt) ->
	options =
		config:
			src: 'grunttask/*.coffee'

	loadGruntTasks grunt
	grunt.initConfig loadGruntConfigs grunt, options

	grunt.registerTask 'travis', ['coffeelint:all']

	grunt.registerTask 'default', ['coffeelint:all']
