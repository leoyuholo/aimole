
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	_makeMatchTag = (gameId, players) ->
		matchTag = "game:#{gameId}/"
		matchTag += _.map(players, (p) -> 'player:' + if p.type == 'submission' then p.submissionId else "ai-#{p.name}").join '/'
		return matchTag

	_get = (matchId) ->
		new $.Parse.Query($.models.Match)
			.get matchId, {useMasterKey: true}

	_new = (newMatch) ->
		matchACL = new $.Parse.ACL()
		matchACL.setPublicWriteAccess false
		matchACL.setPublicReadAccess true
		new $.models.Match()
			.set 'submitBy', newMatch.submitBy
			.set 'gameId', newMatch.gameId
			.set 'state', 'created'
			.set 'players', newMatch.players
			.set 'matchTag', _makeMatchTag newMatch.gameId, newMatch.players
			.setACL matchACL

	self.findByGameIdAndPlayers = (gameId, players, done) ->
		new $.Parse.Query($.models.Match)
			.equalTo 'matchTag', _makeMatchTag gameId, players
			.first {useMasterKey: true}
			.then (match) -> done null, match?.toJSON()
			.fail (err) -> done err

	self.findById = (id, done) ->
		new $.Parse.Query($.models.Match)
			.get id, {useMasterKey: true}
			.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	self.create = (newMatch, done) ->
		_new(newMatch)
			.save null, {useMasterKey: true}
			.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	self.setState = (matchId, state, done) ->
		new $.models.Match({id: matchId})
			.set 'state', state
			.save null, {useMasterKey: true}
			.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	self.addResult = (matchId, result, done) ->
		new $.models.Match({id: matchId})
			.add 'result', result
			.save null, {useMasterKey: true}
			.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	self.finalizeResult = (matchId, result, done) ->
		new $.models.Match({id: matchId})
			.set 'result', result
			.set 'state', 'evaluated'
			.save null, {useMasterKey: true}
			.then (match) -> done null, match?.toJSON?()
			.fail (err) -> done err

	return self
