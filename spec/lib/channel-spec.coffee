EventEmitter = require('events').EventEmitter

describe 'channel', ->

  Given -> @channel = require './../../lib/channel'
  Given -> @name = 'channel'
  Given ->
    @exchange = new EventEmitter
    @exchange.publish = (message, channel) ->

  describe '#make', ->
    When -> @res = @channel.make @name, @exchange
    Then -> expect(typeof @res).toBe 'object'
    And -> expect(@res instanceof @channel).toBe true
    And -> expect(@res.id).toBe @name

  context 'an instance', ->

    Given -> @instance = @channel.make @name, @exchange
    Given -> @message = ok:1

    describe '#publish', ->

      Given -> spyOn(@exchange,['publish']).andCallThrough()
      When -> @instance.publish @message
      Then -> expect(@exchange.publish).toHaveBeenCalledWith @message, @name

    describe 'receiving a message', ->

      Given -> spyOn(@instance,['emit']).andCallThrough()
      When -> @exchange.emit @name, @message
      Then -> expect(@instance.emit).toHaveBeenCalledWith 'message', @message
