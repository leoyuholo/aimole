_ = require 'lodash'

config =
	mongodb:
		db: 'aimole-test'

module.exports = _.defaultsDeep config, require './commonConfig'
