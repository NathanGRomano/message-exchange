EventEmitter = require('events').EventEmitter

describe 'pubsub', ->

  Given -> @pubsub = require './../../lib/pubsub'
  Given ->
    @pub = new EventEmitter
    @pub.publish = (channel, message) ->
  Given ->
    @sub = new EventEmitter
    @sub.subscribe = (channel) ->

  describe '#make', ->

    When -> @res = @pubsub.make @pub, @sub
    Then -> expect(typeof @res).toBe 'object'
    And -> expect(@res instanceof @pubsub).toBe true
    And -> expect(@res.pub).toEqual @pub
    And -> expect(@res.sub).toEqual @sub

  context 'an instance', ->

    Given -> @instance = @pubsub.make @pub, @sub
    Given -> @channel = 'channel'
    Given -> @message = encodeURIComponent(JSON.stringify(ok:1))

    describe '#send', ->

      Given -> spyOn(@pub,['publish']).andCallThrough()
      When -> @instance.send @channel + ' ' + @message
      Then -> expect(@pub.publish).toHaveBeenCalledWith @channel, @message

    describe '#subscribe', ->
      Given -> spyOn(@sub,['subscribe']).andCallThrough()
      When -> @instance.subscribe @channel
      Then -> expect(@sub.subscribe).toHaveBeenCalledWith @channel, jasmine.any(Function)

