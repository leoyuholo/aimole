path = require 'path'

moment = require 'moment'

module.exports =
	port: 3000
	logDir: path.join __dirname, '..', 'logs'
	logFile: "admin-#{moment().format('YYYYMMDD_HHmmss')}.log"
	mongodb:
		host: process.env.MONGODB_PORT_27017_TCP_ADDR || '127.0.0.1'
		port: process.env.MONGODB_PORT_27017_TCP_PORT | 27017
		db: 'aimole'
