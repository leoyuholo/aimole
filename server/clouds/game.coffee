
module.exports = ($) ->
	return (Parse) ->
		Parse.Cloud.beforeSave 'Game', (req, res) ->
			$.logger.info 'before save user', req.object.get 'url'
			res.error('Not implemented yet.')
