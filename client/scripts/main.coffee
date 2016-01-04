
$.ajax('/api/game/list').done (data) ->
	console.log data.games[0].name
