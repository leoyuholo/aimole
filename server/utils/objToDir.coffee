path = require 'path'

_ = require 'lodash'
async = require 'async'
fse = require 'fs-extra'

module.exports = ($) ->
	objToDir = (dir, obj, done) ->
		async.each _.toPairs(obj), ( ([filename, fileContent], done) ->
			filePath = path.join dir, filename
			return fse.outputFile filePath, fileContent, done if _.isString fileContent
			# TODO: handle other data types
			objToDir filePath, fileContent, done if _.isObject fileContent
		), done

	return objToDir
