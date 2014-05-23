EventEmitter = require('events').EventEmitter

describe 'queue', ->

  Given -> @Queue = require './../../lib/queue'
  Given ->
    @kue = new EventEmitter
    @kue.process = (messages, handler) ->
      @handler = handler
    @kue.create = (message, data) ->
      save: =>
        @handler data, ->

  describe '#make', ->

    When -> @res = @Queue.make @kue
    Then -> expect(typeof @res).toBe 'object'
    And -> expect(@res instanceof @Queue).toBe true
    And -> expect(@res.q).toEqual @kue

  context 'an instance', ->

    Given -> @instance = @Queue.make @kue
    Given -> @message = data: action: 'action'

    describe '#send', ->
      Given -> spyOn(@kue,['create']).andCallThrough()
      When -> @instance.send @message
      Then -> expect(@kue.create).toHaveBeenCalledWith 'message', @message

    describe '.q', ->

      context 'receiving a message', ->
        
        Given -> spyOn(@instance,['emit']).andCallThrough()
        When -> @instance.send @message
        Then -> expect(@instance.emit).toHaveBeenCalledWith 'message', @message
