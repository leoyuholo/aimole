
module.exports =
	port: 3000
	Parse:
		appId: 'aimole'
		masterKey: 'aimole-master'
		serverURL: 'http://localhost:3000/parse'
		serverURLPath: '/parse'
	mongodb:
		host: process.env.MONGODB_PORT_27017_TCP_ADDR || process.env.HOST_IP  || 'localhost'
		port: process.env.MONGODB_PORT_27017_TCP_PORT || 27017
		db: 'aimole'
	rabbitmq:
		host: process.env.RABBITMQ_PORT_5672_TCP_ADDR || process.env.HOST_IP  || 'localhost'
		port: process.env.RABBITMQ_PORT_5672_TCP_PORT || 5672
		queues:
			submission: 'submission'
			game: 'game'
