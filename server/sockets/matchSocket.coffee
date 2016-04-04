
_ = require 'lodash'

module.exports = ($) ->
	self = {}

	onError = (socket, err) ->
		return if socket.disconnected
		socket.emit 'err', err.message
		socket.disconnect()

	$.io.of('/match').on 'connection', (socket) ->
		matchId = socket.handshake.query.matchId

		return onError socket, new Error('Missing matchId.') if !matchId
		return onError socket, new Error('Invalid matchId.') if !/^[-\w]+$/.test matchId

		onData = (data) ->
			switch data.event
				when 'data'
					record = data.record
					index = data.index
					socket.emit 'display', record.action.display if record.type == 'action' && record.action?.display
				when 'end'
					socket.emit 'end'
					socket.disconnect()
				else
					onError socket, new Error("Unknow event type #{data.event}")

		$.stores.matchStore.findById matchId, (err, match) ->
			return onError socket, err if err

			match = $.models.Match.envelop match
			_.each match.result, ( (display) -> socket.emit 'display', display) if match.result?.length > 0

			$.utils.amqp.subscribeJSON $.config.rabbitmq.queues.matchStream, matchId, onData, (err, consumerTag) ->
				return $.utils.onError done, err if err

				socket.on 'disconnect', () -> $.utils.amqp.unsubscribe consumerTag, _.noop

				if match.state == 'created'
					$.services.matchService.play matchId, (err, match) ->
						return onError socket, err if err
						socket.disconnect()

	return self
