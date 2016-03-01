app = angular.module 'aimole'

app.service 'submissionService', () ->
	self = {}

	Submission = Parse.Object.extend 'Submission'

	self.submit = (gameObjectId, code) ->
		submission = new submission()
		submission.set 'gameObjectId', gameObjectId
		submission.set 'code', code
		submission.set 'language', 'c'
		submission.setACL new Parse.ACL(Parse.User.current())
		submission.save()

	return self
