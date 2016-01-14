path = require 'path'

async = require 'async'
_ = require 'lodash'
express = require 'express'
bodyParser = require 'body-parser'
winston = require 'winston'
_requireAll = require 'require-all'
requireAll = (dir, injections) ->
	_requireAll
		dirname: dir
		filter: /(.+)\.(coffee|js(on)?)$/
		resolve: (exports) ->
			if _.isFunction exports then exports injections else exports

module.exports = $ = {}

# dirs
$.serverDir = __dirname
$.rootDir = path.join $.serverDir, '..'
$.publicDir = path.join $.rootDir, 'public'
$.gameDir = path.join $.rootDir, 'game'
# $.libDir = path.join $.rootDir, 'bower_components'

# configs
$.config = require path.join $.rootDir, 'configs', 'config'

# express
$.express = express
$.app = express()
$.app.use bodyParser.json {limit: '1000kb'}

# logger
$.logger = new winston.Logger(
	transports: [
		new (winston.transports.Console)({level: 'verbose', colorize: true})
		new (winston.transports.File)({filename: path.join $.config.logDir, $.config.logFile})
	]
)

# initialzation sequence is important
[
	'utils'
	'models'
	'stores'
	'services'
	'controllers'
	'setups'
].forEach (component) ->
	$[component] = requireAll path.join($.serverDir, component), $

$.utils.requireAll = requireAll

# static resources
$.app.use express.static $.publicDir
# $.app.use '/lib', express.static $.libDir

# api
api = express.Router()
if $.controllers.userController
	api.use '/user', $.controllers.userController
_.each $.controllers, (controller, name) ->
	api.use '/' + name.replace(/Controller$/, ''), controller if name != 'userController'
api.use $.utils.errorResponse
$.app.use '/api', api

# methods
$.run =
	setups: (done) ->
		process.nextTick () ->
			async.eachSeries $.setups, ( (setup, done) ->
				setup.run done
			), done

	server: (done) ->
		$.app.listen $.config.port, done
