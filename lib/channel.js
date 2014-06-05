var util = require('util')
  , events = require('events')
//  , Exchange = require('./exchange') 
  ;

/**
 * An Channel is where messages are sent to and receive
 *
 * @param {string} id
 * @param {Exchange} exchange
 */

function Channel (id, exchange) {
  var self = this;
  events.EventEmitter.call(this);
  this.id = id;
  this.exchange = exchange;
  this.exchange.on(this.id, function (message) {
    self.emit('message', message);
  });
  this.setMaxListeners(0);
}

util.inherits(Channel, events.EventEmitter);

/**
 * Makes a new channgel
 *
 * @param {string} id
 * @param {Exchange} exchange
 * @return Channel
 */

Channel.make = function (id, exchange) {
  return new Channel(id, exchange);
};

/**
 * publishes a message onto this channel
 *
 * @param {string} message
 * @return Channel
 */

Channel.prototype.publish = function (message) {
  this.exchange.publish(message, this.id);
  return this;
};

module.exports = Channel;
