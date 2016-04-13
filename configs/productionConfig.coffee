
credentials = require './credentials'

throw new Error('Missing Parse facebookAppIds.') if !credentials?.Parse?.facebookAppIds || credentials.Parse.facebookAppIds.length == 0
throw new Error('Missing Parse masterKey.') if !credentials?.Parse?.masterKey

module.exports =
	env: 'production'
	port: 3000
	httpsPort: 3001
	adminKey: credentials.adminKey
	https:
		key: credentials.https?.key
		cert: credentials.https?.cert
	analytics:
		trackingId: credentials.analytics?.trackingId
	Parse:
		masterKey: credentials.Parse.masterKey
		serverURL: credentials.Parse.serverURL
		facebookAppIds: credentials.Parse.facebookAppIds
	mongodb:
		db: 'aimole-prod'
