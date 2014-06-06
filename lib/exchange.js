var util = require('util')
  , events = require('events')
  , Queue = require('./queue')
  , PubSub = require('./pubsub')
  , Channel = require('./channel')
  ;

/**
 * We use an exchange to send data accross the network
 * using a queue and pubsub. Data is written to a queue, when a message is received
 * off of the queue, the queue parses it and emits and event.  The event handler is given
 * a callback that will publish the processed event on the pub sub given the actors channel / userid
 * any listeners on that channel will be notified and given the message
 *
 * NOTE we could probably use only event emitter instead of the "send" methods of the Queue and PubSub objects
 *
 * @param {Queue} queue Messages are written to the queue, processed by the queue, and dispatched to the pubsub
 * @param {PubSub} pubsub The pubsub will push message to the pubsub and receives messages from the pubsub as well as dispatch received messages to the handler.
 * @param {EventEmitter} handler The handler will handle messages from the Queue 
 */

module.exports = Exchange;

function Exchange (queue, pubsub, handler) {

  events.EventEmitter.call(this);

  var self = this;

  this.onQueueMessage = function (message) {
    try {
      self.handler().emit(message.data.action, message.data, self);
    } catch(e) {
      console.error(e);
    }
  };

  //we the pubsub receives a message have the Exchange emit an event given the channel we received the message on
  this.onPubSubMessage = function (message) {
    try {
      var parts = message.toString().split(' ')
        , channel = parts.shift()
        , data = JSON.parse(decodeURIComponent(parts.shift().toString()));
      self.emit(channel, data); 
    }
    catch(e) {
      console.error(e);
    }
  };

  // list(s) of channels

  this.channels = {};

  this.setMaxListeners(0);

  if (queue) this.queue(queue);

  if (pubsub) this.pubsub(pubsub);

  if (handler) this.handler(handler);
}

util.inherits(Exchange, events.EventEmitter);

/**
 * Make a new exchange
 *
 * @param {Queue} queue Messages are written to the queue, processed by the queue, and dispatched to the pubsub
 * @param {PubSub} pubsub The pubsub will push message to the pubsub and receives messages from the pubsub as well as dispatch received messages to the handler.
 * @param {EventEmitter} handler The handler will handle messages from the Queue 
 * @return Exchange
 */

Exchange.make = function (queue, pubsub, handler) {
  return new Exchange(queue, pubsub, handler);
};

/**
 * publish a message to the queue or if the channel is specified to the channel
 *
 * @param {string} message
 * @param {string} channel *optional
 * @return Exchange
 */

Exchange.prototype.publish = function (message, channel) {
  if (channel) {
    this.pubsub().send(channel + ' ' + encodeURIComponent(JSON.stringify(message)));
  }
  else {
    this.queue().send(message);
  }
  return this;
};

/**
 * Gets a Channel if it has been initialized or initializes a Channel binding
 * it to the exchange
 *
 * @return Channel
 */

Exchange.prototype.channel = function (channel) {
  if (!this.channels[channel]) {
    this.channels[channel] = Channel.make(channel, this);
    this.pubsub().subscribe(channel);
  }
  return this.channels[channel];
};

/**
 * Gets or sets the queue as well as initializes it
 *
 * @param {Queue} queue
 * @return Queue / Exchange
 */

Exchange.prototype.queue = function (queue) {

  if (typeof queue === 'object' && queue instanceof Queue) {

    if (this._queue) {
      this._queue.removeListener('message', this.onQueueMessage);
    }
    
    this._queue = queue;
    this._queue.on('message', this.onQueueMessage);

    return this;
  }

  if (!this._queue) {
    this.queue( Queue.make() );
  }

  return this._queue;

}

/**
 * Gets or sets the pubsub as well as initializes it
 *
 * @param {PubSub} pubsub
 * @return PubSub / Exchange
 */

Exchange.prototype.pubsub = function (pubsub) {

  if (typeof pubsub === 'object' && pubsub instanceof PubSub) {

    if (this._pubsub) {
      this._pubsub.removeListener('message', this.onPubSubMessage);
    }
    
    this._pubsub = pubsub;
    this._pubsub.on('message', this.onPubSubMessage);

    return this;
  }

  if (!this._pubsub) {
    this.pubsub( PubSub.make() );
  }

  return this._pubsub;

};

/**
 * Sets or Gets the handler
 *
 * @param {EventEmitter} handler
 * @return EventEmitter / Exchange
 */

Exchange.prototype.handler = function (handler) {

  if (typeof handler === 'object' && handler instanceof events.EventEmitter) {
    this._handler = handler;
    return this;
  }

  if (!this._handler) {
    this.handler( new PubSub() );
  }

  return this._handler;
};
