
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	_new = (newMatch) ->
		matchACL = new $.Parse.ACL()
		matchACL.setPublicWriteAccess false
		matchACL.setPublicReadAccess true
		new $.models.Match()
			.set 'submitBy', newMatch.submitBy
			.set 'gameId', newMatch.gameId
			.set 'status', 'created'
			.set 'players', newMatch.players
			.setACL matchACL

	self.findById = (id, done) ->
		done = _.partial _.defer, done
		new $.Parse.Query($.models.Match)
			.get id, {useMasterKey: true}
			.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	self.create = (newMatch, done) ->
		done = _.partial _.defer, done

		_new(newMatch)
			.save null, {userMasterKey: true}
			.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	self.updateResult = (matchId, result, done) ->
		done = _.partial _.defer, done

		new $.Parse.Query($.models.Match)
			.get matchId, {useMasterKey: true}
			.then (match) ->
				return done new Error("Match not found for id [#{matchId}].") if !match
				match.set 'result', result
					.save null, {useMasterKey: true}
					.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	return self
