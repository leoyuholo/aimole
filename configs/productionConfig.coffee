_ = require 'lodash'

config =
	mongodb:
		db: 'aimole-prod'

module.exports = _.defaultsDeep config, require './commonConfig'
