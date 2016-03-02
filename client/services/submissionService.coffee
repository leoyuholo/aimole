app = angular.module 'aimole'

app.service 'submissionService', () ->
	self = {}

	Submission = Parse.Object.extend 'Submission'

	self.submit = (gameObjectId, code) ->
		submission = new Submission()
		submission.set 'user', Parse.User.current()
		submission.set 'gameObjectId', gameObjectId
		submission.set 'code', code
		submission.set 'language', 'c'
		submissionACL = new Parse.ACL(Parse.User.current())
		submissionACL.setRoleReadAccess 'Administrator', true
		submission.setACL submissionACL
		submission.save()

	return self
