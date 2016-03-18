_ = require 'lodash'

config =
	Parse:
		facebookAppIds: ['123456789012345']
	mongodb:
		db: 'aimole-dev'

module.exports = _.defaultsDeep config, require './commonConfig'
