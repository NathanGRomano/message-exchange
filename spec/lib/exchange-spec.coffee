EventEmitter = require('events').EventEmitter
describe 'exchange', ->

  Given -> @exchange = require './../../lib/exchange'
  Given ->
    @q = new EventEmitter
    @q.send = ->
  Given ->
    @p = new EventEmitter
    @p.send = ->
    @p.subscribe = ->
  Given -> @h = new EventEmitter

  describe '#make', ->

    context 'with no arguments', ->

      When -> @res = @exchange.make()
      Then -> expect(typeof @res).toBe 'object'
      And -> expect(@res instanceof @exchange).toBe true

    context 'with queue, pubsub, handler', ->
      When -> @res = @exchange.make @q, @p, @h
      Then -> expect(typeof @res).toBe 'object'
      And -> expect(@res instanceof @exchange).toBe true
      And -> expect(@res.queue).toBe @q
      And -> expect(@res.pubsub).toBe @p
      And -> expect(@res.handler).toBe @h

  context 'an instance', ->

    Given -> @instance = @exchange.make @q, @p, @h

    describe '#publish', ->

      context 'with message and channel', ->
        Given -> spyOn(@p,['send']).andCallThrough()
        When -> @instance.publish ok:1, 'channel'
        Then -> expect(@p.send).toHaveBeenCalledWith 'channel ' + encodeURIComponent(JSON.stringify(ok:1))

      context 'with message', ->
        Given -> spyOn(@q, ['send']).andCallThrough()
        When -> @instance.publish ok:2
        Then -> expect(@q.send).toHaveBeenCalledWith ok:2

    describe '#channel', ->

      When -> @res = @instance.channel 'channel'
      Then -> expect(typeof @res).toBe 'object'
      And -> expect(@res.id).toBe 'channel'

    describe '.handler', ->
      
      Given -> @message =
          data:
            action:'action'
    
      context 'receiving a message on a queue', ->

        Given -> spyOn(@instance.handler,['emit']).andCallThrough()
        When -> @q.emit 'message', @message
        Then -> expect(@instance.handler.emit).toHaveBeenCalledWith 'action', @message.data, @instance

    describe '.pubsub', ->

      Given -> @message = 'channel ' + encodeURIComponent(JSON.stringify(ok:4))

      context 'receiving a mesage on the pubsub', ->
        Given -> spyOn(@instance,['emit']).andCallThrough()
        When -> @p.emit 'message', @message
        Then -> expect(@instance.emit).toHaveBeenCalledWith 'channel', ok:4
