
try credentials = require './credentials'

module.exports =
	env: 'development'
	Parse:
		facebookAppIds: credentials?.Parse?.facebookAppIds || ['123456789012345']
	mongodb:
		db: 'aimole-dev'
