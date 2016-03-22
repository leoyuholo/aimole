
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	_makeMatchTag = (gameId, players) ->
		matchTag = "game:#{gameId}/"
		matchTag += _.map(players, (p) -> 'player:' + if p.type == 'submission' then p.submissionId else "ai-#{p.name}").join '/'
		return matchTag

	_new = (newMatch) ->
		matchACL = new $.Parse.ACL()
		matchACL.setPublicWriteAccess false
		matchACL.setPublicReadAccess true
		new $.models.Match()
			.set 'submitBy', newMatch.submitBy
			.set 'gameId', newMatch.gameId
			.set 'status', 'created'
			.set 'players', newMatch.players
			.set 'matchTag', _makeMatchTag newMatch.gameId, newMatch.players
			.setACL matchACL

	self.findByGameIdAndPlayers = (gameId, players, done) ->
		done = _.partial _.defer, done
		new $.Parse.Query($.models.Match)
			.equalTo 'matchTag', _makeMatchTag gameId, players
			.first {useMasterKey: true}
			.then (match) -> done null, match?.toJSON()
			.fail (err) -> done err

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

	self.finalizeResult = (matchId, result, done) ->
		done = _.partial _.defer, done

		new $.Parse.Query($.models.Match)
			.get matchId, {useMasterKey: true}
			.then (match) ->
				return done new Error("Match not found for id [#{matchId}].") if !match
				match.set 'result', result
					.set 'status', 'evaluated'
					.save null, {useMasterKey: true}
					.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	return self
