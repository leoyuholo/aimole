path = require 'path'

express = require 'express'

module.exports = $ = {}

$.serverDir = __dirname
$.rootDir = path.join $.serverDir, '..'
$.publicDir = path.join $.rootDir, 'public'

$.config = require path.join $.rootDir, 'configs', 'config'

$.express = express
$.app = express()

$.app.use express.static $.publicDir
