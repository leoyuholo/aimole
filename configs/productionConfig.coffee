
credentials = require './credentials'

throw new Error('Missing Parse facebookAppIds.') if !credentials?.Parse?.facebookAppIds || credentials.Parse.facebookAppIds.length == 0
throw new Error('Missing Parse masterKey.') if !credentials?.Parse?.masterKey

module.exports =
	env: 'production'
	port: 3000
	httpsPort: 3001
	https:
		key: credentials.https?.key
		cert: credentials.https?.cert
	Parse:
		masterKey: credentials.Parse.masterKey
		serverURL: if process.env.HOST_IP then "http://#{process.env.HOST_IP}/parse" else 'http://localhost/parse'
		facebookAppIds: credentials.Parse.facebookAppIds
	mongodb:
		db: 'aimole-prod'
