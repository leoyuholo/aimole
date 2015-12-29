path = require 'path'

express = require 'express'
_requireAll = require 'require-all'
requireAll = (dir, injections) ->
	_requireAll
		dirname: dir
		filter: /(.+)\.(coffee|js(on)?)$/

module.exports = $ = {}

$.serverDir = __dirname
$.rootDir = path.join $.serverDir, '..'
$.publicDir = path.join $.rootDir, 'public'
$.libDir = path.join $.rootDir, 'bower_components'

$.config = require path.join $.rootDir, 'configs', 'config'

$.express = express
$.app = express()

$.controllers = requireAll path.join $.serverDir, 'controllers'

$.app.use express.static $.publicDir
$.app.use '/lib', express.static $.libDir

api = express.Router()
api.use '/user', $.controllers.userController
api.use '/game', $.controllers.gameController
$.app.use '/api', api
