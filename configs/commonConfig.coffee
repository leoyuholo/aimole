path = require 'path'

module.exports =
	port: 3000
	workerDir: process.env.WORKER_DIR || path.join '/', 'tmp', 'worker'
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
