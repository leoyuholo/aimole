
module.exports = self = {}

self.list = (done) ->
	done null, [
		{
			name: 'tic-tac-toe'
			difficulty: 'easy'
		},
		{
			name: '2048'
			difficulty: 'intermediate'
		}
	]
