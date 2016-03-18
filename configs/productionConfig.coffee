_ = require 'lodash'

config =
	Parse:
		serverURL: if process.env.HOST_IP then "http://#{process.env.HOST_IP}/parse" else 'http://localhost:3000/parse'
	mongodb:
		db: 'aimole-prod'

module.exports = _.defaultsDeep config, require './commonConfig'
