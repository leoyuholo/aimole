path = require 'path'
events = require 'events'
http = require 'http'
https = require 'https'

_ = require 'lodash'
async = require 'async'
express = require 'express'
socketio = require 'socket.io'
bodyParser = require 'body-parser'
compression = require 'compression'
forceSSL = require 'express-force-ssl'
winston = require 'winston'
morgan = require 'morgan'
parseServer = require 'parse-server'
ParseConfig = require 'parse-server/lib/Config'
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
	# console.log 'config', _.omit $.config, 'https'

	# https and socket.io
	$.httpsServer = https.createServer {key: $.config.https.key, cert: $.config.https.cert}, $.app if $.config.https?.key && $.config.https?.cert
	$.httpServer = http.createServer $.app
	$.io = socketio $.httpsServer || $.httpServer

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
		$.app.use morgan 'tiny', {skip: ( (req, res) -> /(^\/libs\/|^\/$|^\/favicon.ico$|\.map$)/.test req.path), stream: {write: (msg) -> $.logger.info msg}}

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
		'sockets'
	].forEach (component) ->
		$[component] = requireAll path.join(__dirname, component), $
	$.utils.requireAll = requireAll

	# methods
	$.run = {}
	$.run.setup = (done) ->
		process.nextTick () ->
			async.eachSeries $.setups, ( (setup, done) ->
				setup.run done
			), done
	$.run.server = (done) ->
		$.app.use forceSSL if $.httpsServer

		# routes
		$.app.use $.express.static $.publicDir
		$.app.use $.config.Parse.serverURLPath, new parseServer.ParseServer(
			databaseURI: "mongodb://#{$.config.mongodb.host}:#{$.config.mongodb.port}/#{$.config.mongodb.db}"
			appId: $.config.Parse.appId
			masterKey: $.config.Parse.masterKey
			serverURL: $.config.Parse.serverURL
			facebookAppIds: $.config.Parse.facebookAppIds
			allowClientClassCreation: false
			cloud: (Parse) ->
				$.Parse = Parse
				$.Parse.Cloud.useMasterKey()
				_.each $.clouds, (cloud) -> cloud Parse
		)

		$.httpsServer.listen $.config.httpsPort if $.httpsServer
		$.httpServer.listen $.config.port, () ->
			$.emitter.emit 'serverStarted'
			done null
	$.run.parseSchemaSetup = (done) ->
		return done null if !$.config.env.production
		initSchema = (modelName, model, schema, done) ->
			new model()
				.save null, {useMasterKey: true}
				.then (modelObj) -> modelObj.destroy {useMasterKey: true}
				.then () -> schema.setPermissions modelName, model.parsePermissions || $.constants.parsePermissions.grantNone
				.then () -> done null
				.fail (err) -> done err

		new ParseConfig($.config.Parse.appId, '/parse')
			.database.loadSchema()
			.then (schema) ->
				async.forEachOf $.models, ( (model, modelName, done) ->
					initSchema modelName, model, schema, done
				), (err) -> done err
			.catch (err) -> done err
	$.run.analysisWorker = (done) ->
		$.services.workerService.registerAnalysisWorker done
	$.run.playMatchWorker = (done) ->
		$.services.workerService.registerPlayMatchWorker done

	return $
