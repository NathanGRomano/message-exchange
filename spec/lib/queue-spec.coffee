EventEmitter = require('events').EventEmitter

describe 'queue', ->

  Given ->
    @Kue = class Kue extends EventEmitter
      process: (message, handler) ->
        @handler = handler
      create: (message, data) ->
        save: =>
          @handler data, ->
    @Kue.createClient = -> new Kue

  Given -> @client = @Kue.createClient()

  Given -> @Queue = requireSubject 'lib/queue', {
    'kue': @Kue
  }

  describe '#make', ->

    When -> @res = @Queue.make @client
    Then -> expect(typeof @res).toBe 'object'
    And -> expect(@res instanceof @Queue).toBe true
    And -> expect(@res.q).toEqual @client

  context 'an instance', ->

    Given -> @instance = @Queue.make @client
    Given -> @message = data: action: 'action'

    describe '#send', ->
      Given -> spyOn(@client,['create']).andCallThrough()
      When -> @instance.send @message
      Then -> expect(@client.create).toHaveBeenCalledWith 'message', @message

    describe '.q', ->

      context 'receiving a message', ->
        
        Given -> spyOn(@instance,['emit']).andCallThrough()
        When -> @instance.send @message
        Then -> expect(@instance.emit).toHaveBeenCalledWith 'message', @message
