Lib = require('./..')
Queue = Lib.Queue
PubSub = Lib.PubSub
Exchange = Lib.Exchange
EventEmitter = Lib.EventEmiter

describe 'message exchange', ->

  describe 'publish a message to a queue, handling the message, and broadcasting on the pubsub', ->

    Given -> @fn = jasmine.createSpy 'fn'
    Given -> @q = Queue.make()
    Given -> @p = PubSub.make()
    Given ->
      @h = new EventEmitter
      @h.on 'action', (event, exchange) -> exchange.channel('channel').publish(event)
    Given ->
      @e = Exchange.make @q, @p, @h
      @e.channel('channel').on 'message', @fn 
    When -> @e.publish action:'action'
    And -> expect(@fn).toHaveBeenCalled()
