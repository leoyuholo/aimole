
async = require 'async'

$ = require './globals'

injectRootUser = (done) ->
	query = new $.Parse.Query($.Parse.User)
	query.equalTo 'username', $.config.rootUser.email
	query.find()
		.then (users) ->
			if users.length > 0
				$.logger.info 'root user exist, login as root user.'
				return $.Parse.User.logIn $.config.rootUser.email, $.config.rootUser.password

			addRootUser = () ->
				user = new $.Parse.User()

				user.set 'username', $.config.rootUser.email
				user.set 'password', $.config.rootUser.password
				user.set 'email', $.config.rootUser.email

				user.signUp null

			addAdminRole = (user) ->
				roleACL = new Parse.ACL()
				roleACL.setPublicReadAccess true
				role = new Parse.Role('Administrator', roleACL)
				role.getUsers().add user

				role.save()

			addRootUser()
				.then addAdminRole
				.then () -> $.logger.info "root user #{$.config.rootUser.email} added with role 'Administrator'."
		.then () -> done null
		.fail (err) -> $.utils.onError done, err

async.series [
	$.run.setup
	$.run.server
	injectRootUser
], (err) ->
	return $.logger.error "error starting up aimole #{err.message}" if err
	$.logger.info "[#{$.app.get 'env'}] aimole listen on port #{$.config.port}"
