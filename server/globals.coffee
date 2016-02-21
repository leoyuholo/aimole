path = require 'path'
events = require 'events'

_ = require 'lodash'
async = require 'async'
express = require 'express'
bodyParser = require 'body-parser'
compression = require 'compression'
winston = require 'winston'
morgan = require 'morgan'
ParseServer = require('parse-server').ParseServer
_requireAll = require 'require-all'
requireAll = (dir, injections...) ->
	_requireAll
		dirname: dir
		filter: /(.+)\.(coffee|js(on)?)$/
		resolve: (exports) ->
			if _.isFunction exports then exports injections... else exports

module.exports = $ = {}

# dirs
$.serverDir = __dirname
$.rootDir = path.join $.serverDir, '..'
$.publicDir = path.join $.rootDir, 'public'
$.tmpDir = path.join $.rootDir, 'tmp'

# configs
$.config = require path.join $.rootDir, 'configs', 'config'

# emitters
$.emitter = new events.EventEmitter()

# express
$.express = express
$.app = express()
$.app.use bodyParser.json {limit: '10mb'}
# $.app.use bodyParser.urlencoded {extended: true}
$.app.use compression()

# env
$.env = $.env || {}
$.env.development = $.app.get('env') == 'development'
$.env.production = $.app.get('env') == 'production'

# logger
$.logger = new winston.Logger(
	transports: [
		new (winston.transports.Console)(
			level: 'verbose'
			json: false
			colorize: true
		)
		new (winston.transports.File)(
			level: 'info'
			filename: path.join $.rootDir, 'logs', 'all-logs.log'
			handleExceptions: !!$.env.production
			json: true
			maxsize: 5 * 1024 * 1024
			maxFiles: 10
			colorize: false
		)
	]
	exitOnError: false
)
$.app.use morgan 'tiny', {stream: {write: (msg) -> $.logger.info msg}}

# initialzation sequence is important
[
	'utils'
	'setups'
	'services'
	'listeners'
	'clouds'
].forEach (component) ->
	$[component] = requireAll path.join(__dirname, component), $
$.utils.requireAll = requireAll

# routes
$.app.use $.express.static $.publicDir
$.app.use $.config.Parse.serverURLPath, new ParseServer(
	databaseURI: "mongodb://#{$.config.mongodb.host}:#{$.config.mongodb.port}/#{$.config.mongodb.db}"
	appId: $.config.Parse.appId
	masterKey: $.config.Parse.masterKey
	serverURL: $.config.Parse.serverURL
	cloud: (Parse) -> _.each $.clouds, (cloud) -> cloud Parse
)

# methods
$.run = {}
$.run.setup = (done) ->
	process.nextTick () ->
		async.eachSeries $.setups, ( (setup, done) ->
			setup.run done
		), done
$.run.server = (done) ->
	$.app.listen $.config.port, (err) ->
		return $.utils.onError done, err if err

		$.emitter.emit 'serverStarted'

		done null
