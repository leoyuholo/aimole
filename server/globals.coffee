path = require 'path'
events = require 'events'
http = require 'http'
https = require 'https'

_ = require 'lodash'
async = require 'async'
express = require 'express'
bodyParser = require 'body-parser'
compression = require 'compression'
winston = require 'winston'
morgan = require 'morgan'
parseServer = require 'parse-server'
_requireAll = require 'require-all'
requireAll = (dir, injections...) ->
	_requireAll
		dirname: dir
		filter: /(.+)\.(coffee|js(on)?)$/
		resolve: (exports) ->
			if _.isFunction exports then exports injections... else exports

module.exports = ($) ->

	# express
	$.express = express
	$.app = express()
	$.app.use bodyParser.json {limit: '10mb'}
	# $.app.use bodyParser.urlencoded {extended: true}
	$.app.use compression()

	# env
	$.env = $.env || {}
	$.env.testing = $.app.get('env') == 'testing'
	$.env.development = $.app.get('env') == 'development'
	$.env.production = $.app.get('env') == 'production'

	# dirs
	$.serverDir = __dirname
	$.rootDir = path.join $.serverDir, '..'
	$.publicDir = path.join $.rootDir, 'public'
	$.tmpDir = path.join $.rootDir, 'tmp'

	# configs
	$.config = require path.join $.rootDir, 'configs', 'config'

	# config defined dirs
	$.workerDir = $.config.workerDir

	# emitters
	$.emitter = new events.EventEmitter()

	# logger
	$.logger = new winston.Logger(
		transports: [
			new winston.transports.Console(
				level: 'verbose'
				json: false
				colorize: true
			)
			new winston.transports.File(
				level: 'info'
				filename: path.join $.rootDir, 'logs', 'all-logs.log'
				handleExceptions: !!$.env.production
				json: true
				maxsize: 100 * 1024 * 1024
				maxFiles: 10
				colorize: false
			)
		]
		exitOnError: false
	)
	if !$.env.testing
		$.app.use morgan 'tiny', {skip: ( (req, res) -> /(^\/libs\/|^\/$)/.test req.path), stream: {write: (msg) -> $.logger.info msg}}

	# initialzation sequence is important
	[
		'constants'
		'utils'
		'models'
		'stores'
		'services'
		'setups'
		'listeners'
		'clouds'
	].forEach (component) ->
		$[component] = requireAll path.join(__dirname, component), $
	$.utils.requireAll = requireAll

	# console.log 'config', $.config
	useHttps = $.config.https.key && $.config.https.cert

	# methods
	$.run = {}
	$.run.setup = (done) ->
		process.nextTick () ->
			async.eachSeries $.setups, ( (setup, done) ->
				setup.run done
			), done
	$.run.server = (done) ->
		# routes
		$.app.use $.express.static $.publicDir
		$.app.use $.config.Parse.serverURLPath, new parseServer.ParseServer(
			databaseURI: "mongodb://#{$.config.mongodb.host}:#{$.config.mongodb.port}/#{$.config.mongodb.db}"
			appId: $.config.Parse.appId
			masterKey: $.config.Parse.masterKey
			serverURL: if $.useHttps then 'https://localhost/parse' else "http://localhost:#{$.config.port}/parse"
			facebookAppIds: $.config.Parse.facebookAppIds
			cloud: (Parse) -> _.each $.clouds, (cloud) -> cloud Parse
		)

		if useHttps
			https.createServer({key: $.config.https.key, cert: $.config.https.cert}, $.app).listen $.config.httpsPort, () ->
				$.emitter.emit 'serverStarted'
				done null
		else
			$.app.listen $.config.port, () ->
				$.emitter.emit 'serverStarted'
				done null
	$.run.parseSchemaSetup = (done) ->
		done null
	$.run.analysisWorker = (done) ->
		$.services.workerService.registerAnalysisWorker done
	$.run.playMatchWorker = (done) ->
		$.services.workerService.registerPlayMatchWorker done

	return $
