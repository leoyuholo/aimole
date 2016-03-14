_ = require 'lodash'

config =
	mongodb:
		db: 'aimole-dev'

module.exports = _.defaultsDeep config, require './commonConfig'
