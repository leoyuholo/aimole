
program = require 'commander'
Parse = require 'parse/node'

program
	.option('-i, --appId <id>', 'Parse appId')
	.option('-s, --serverURL <url>', 'Parse serverURL')
	.option('-k, --adminKey <secret>', 'adminKey')
	.option('-u, --githubUrl <url>', 'GitHub Url')
	.parse process.argv

exit = (msg) ->
	console.log msg
	process.exit 0

exit 'Missing Parse appId.' if !program.appId
exit 'Missing Parse serverURL.' if !program.serverURL
exit 'Missing adminKey.' if !program.adminKey
exit 'Missing GitHub Url.' if !program.githubUrl

Parse.initialize program.appId
Parse.serverURL = program.serverURL

Parse.Cloud.run 'installGame', {adminKey: program.adminKey, githubUrl: program.githubUrl}
	.then (game) -> exit "game [#{program.githubUrl}] installed."
	.fail (err) -> exit "error installing game [#{program.githubUrl}]: #{err.message}"
