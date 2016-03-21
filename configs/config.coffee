path = require 'path'

_ = require 'lodash'

defaultConfig =
	env: 'development'
	port: 3000
	httpsPort: 3001
	workerDir: process.env.WORKER_DIR || path.join '/', 'tmp', 'worker'
	https:
		key: ''
		cert: ''
	analytics:
		trackingId: ''
	Parse:
		appId: 'aimole'
		masterKey: 'aimole-master'
		serverURL: 'http://localhost:3000/parse'
		serverURLPath: '/parse'
		facebookAppIds: ['123456789012345']
	mongodb:
		host: process.env.MONGODB_PORT_27017_TCP_ADDR || process.env.HOST_IP  || 'localhost'
		port: process.env.MONGODB_PORT_27017_TCP_PORT || 27017
		db: 'aimole'
	rabbitmq:
		host: process.env.RABBITMQ_PORT_5672_TCP_ADDR || process.env.HOST_IP  || 'localhost'
		port: process.env.RABBITMQ_PORT_5672_TCP_PORT || 5672
		queues:
			codeAnalysis: 'codeAnalysis'
			playMatch: 'playMatch'

config = {}
switch process.env.NODE_ENV
	when 'production'
		config = require './productionConfig'
	when 'testing'
		config = require './testingConfig'
	else
		config = require './developmentConfig'

module.exports = _.defaultsDeep config, defaultConfig
