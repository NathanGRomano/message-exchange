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

function Exchange (queue, pubsub, handler) {

  events.EventEmitter.call(this);

  var self = this;

  // create a hnalder if we didn't get one
  this.handler = handler || new events.EventEmitter();

  // create a queue if we didn't get one
  this.queue = queue || new Queue();

  //when the queue receives a message have the handler emit an event given the data and reference to the exchange
  this.queue.on('message', function (message) {
    try {
      self.handler.emit(message.data.action, message.data, self);
    } catch(e) {
      console.error(e);
    }
  });


  //create a pubsub if we didn't get one

  this.pubsub = pubsub || new PubSub();

  //we the pubsub receives a message have the Exchange emit an event given the channel we received the message on
  this.pubsub.on('message', function (message) {
    try {
      var parts = message.toString().split(' ')
        , channel = parts.shift()
        , data = JSON.parse(decodeURIComponent(parts.shift().toString()));
      self.emit(channel, data); 
    }
    catch(e) {
      console.error(e);
    }
  });

  // list(s) of channels

  this.channels = {};

  this.setMaxListeners(0);
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
 * @param {string} channe *optional
 * @return Exchange
 */

Exchange.prototype.publish = function (message, channel) {
  if (channel) {
    this.pubsub.send(channel + ' ' + encodeURIComponent(JSON.stringify(message)));
  }
  else {
    this.queue.send(message);
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
    this.pubsub.subscribe(channel);
  }
  return this.channels[channel];
};

module.exports = Exchange;
