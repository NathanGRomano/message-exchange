EventEmitter = require('events').EventEmitter

describe 'exchange', ->

  Given ->
    @Queue = class Queue extends EventEmitter
      send: ->
    @Queue.make = -> new Queue

  Given ->
    @PubSub = class PubSub extends EventEmitter
      send: ->
      subscribe: ->
    @PubSub.make = -> new PubSub

  Given ->
    @Exchange = requireSubject 'lib/exchange', {
      './queue': @Queue,
      './pubsub': @PubSub
    }

  Given -> @q = @Queue.make()
  Given -> @p = @PubSub.make()
  Given -> @h = new EventEmitter

  describe '#make', ->

    When -> @res = @Exchange.make()
    Then -> expect(typeof @res).toBe 'object'
    And -> expect(@res instanceof @Exchange).toBe true

    context 'queue:Queue, pubsub:PubSub, handler:EventEmitter', ->
      
      When -> @res = @Exchange.make @q, @p, @h
      Then -> expect(typeof @res).toBe 'object'
      And -> expect(@res instanceof @Exchange).toBe true

  context 'an instance', ->

    Given -> @instance = @Exchange.make @q, @p, @h

    describe '#publish', ->

      context 'message:Object, channel:String', ->
        Given -> spyOn(@p,['send']).andCallThrough()
        When -> @instance.publish ok:1, 'channel'
        Then -> expect(@p.send).toHaveBeenCalledWith 'channel ' + encodeURIComponent(JSON.stringify(ok:1))

      context 'message:Object', ->
        Given -> spyOn(@q, ['send']).andCallThrough()
        When -> @instance.publish ok:2
        Then -> expect(@q.send).toHaveBeenCalledWith ok:2

    describe '#channel', ->

      When -> @res = @instance.channel 'channel'
      Then -> expect(typeof @res).toBe 'object'
      And -> expect(@res.id).toBe 'channel'

    describe '#queue', ->

      When -> @res = @instance.queue()
      Then -> expect(@res instanceof @Queue).toBe true
      And -> expect(@res.listeners('message')[0]).toEqual @instance.onQueueMessage

      context 'queue:Queue', ->

        Given -> @q = @Queue.make()
        Given -> @existing = @instance.queue()
        Given -> spyOn(@existing,['removeListener']).andCallThrough()
        Given -> spyOn(@q,['on']).andCallThrough()
        When -> @res = @instance.queue(@q).queue()
        Then -> expect(@res instanceof @Queue).toBe true
        And -> expect(@res).toEqual @q
        And -> expect(@existing.removeListener).toHaveBeenCalledWith 'message', @instance.onQueueMessage
        And -> expect(@q.on).toHaveBeenCalledWith 'message', @instance.onQueueMessage

    describe '#pubsub', ->

      When -> @res = @instance.pubsub()
      Then -> expect(@res instanceof @PubSub).toBe true
      And -> expect(@res.listeners('message')[0]).toEqual @instance.onPubSubMessage

      context 'pubsub:PubSub', ->

        Given -> @q = @PubSub.make()
        Given -> @existing = @instance.pubsub()
        Given -> spyOn(@existing,['removeListener']).andCallThrough()
        Given -> spyOn(@q,['on']).andCallThrough()
        When -> @res = @instance.pubsub(@q).pubsub()
        Then -> expect(@res instanceof @PubSub).toBe true
        And -> expect(@res).toEqual @q
        And -> expect(@existing.removeListener).toHaveBeenCalledWith 'message', @instance.onPubSubMessage
        And -> expect(@q.on).toHaveBeenCalledWith 'message', @instance.onPubSubMessage

    describe '#handler', ->

      When -> @res = @instance.handler()
      Then -> expect(@res instanceof EventEmitter).toBe true

      context 'handler:EventEmitter', ->

        Given -> @handler = new EventEmitter
        When -> @res = @instance.handler(@handler).handler()
        Then -> expect(@res).toBe @handler

    describe '#onQueueMessage message:Object', ->

      Given -> @message =
        data:
          actor: 'me'
          action: 'shout'
          content: 'hello'
          target: 'you'
      Given -> @handler = @instance.handler()
      Given -> spyOn(@handler, ['emit']).andCallThrough()
      When -> @instance.onQueueMessage @message
      Then -> expect(@handler.emit).toHaveBeenCalledWith @message.data.action, @message.data, @instance

    describe '#onPubSubMessage message:Object', ->

      Given -> @channel = 'channel'
      Given -> @message =
        data:
          actor: 'me'
          action: 'shout'
          content: 'hello'
          target: 'you'
      Given -> spyOn(@instance, ['emit']).andCallThrough()
      When -> @instance.onPubSubMessage @channel + ' ' + encodeURIComponent(JSON.stringify(@message))
      Then -> expect(@instance.emit).toHaveBeenCalledWith @channel, @message
