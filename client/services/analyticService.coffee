app = angular.module 'aimole'

app.service 'analyticService', ($analytics, userService) ->
	self = {}

	disableTracking = false

	self.trackGame = (game, eventName) ->
		self.track eventName, {
			category: game.name
		}

	self.trackPlayers = (game, players, eventName) ->
		involveMe = _.filter(players, (p) -> p.type == 'me').length > 0
		self.trackGame game, if involveMe then 'runCode' else 'runAi'

		_.each players, (p) ->
			self.track 'beSelected', {
				category: game.name
				label: if p.name then p.name else p.type
			}

	self.trackActiveEditing = (game, since) ->
		now = new Date()
		self.track 'activeEditing', {
			category: game.name
			label: "#{now.getFullYear()} #{now.getMonth()} #{now.getDate()}"
			value: now - since
		}

	viewWhoisplayingCount = 0
	self.trackViewWhoisplaying = () ->
		viewWhoisplayingCount = viewWhoisplayingCount + 1
		self.track 'viewWhoisplaying', {
			category: 'user'
			label: userService.getUser()?.displayName || 'anonymous'
			value: viewWhoisplayingCount
		}

	self.track = (eventName, options) ->
		$analytics.eventTrack eventName, options

	self.setUserId = () ->
		user = userService.getUser()
		return $analytics.setUsername user.id if user

		anonymousUserId = localStorage.getItem 'anonymousUserId'
		if !anonymousUserId
			anonymousUserId = window.uuid.v4()
			localStorage.setItem 'anonymousUserId', anonymousUserId
		$analytics.setUsername "anonymous-#{anonymousUserId}"

	if disableTracking
		self.track = _.noop
		self.setUserId = _.noop

	return self
