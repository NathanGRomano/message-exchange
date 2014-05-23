var util = require('util')
  , events = require('events')
  , redis = require('redis')
  ;

/*
 * We use the PubSub to publish messages to everyone that is subscribed
 */

function PubSub (pub, sub) {
  events.EventEmitter.call(this);
  var self = this;

  //create a redis socket for publishing and connect to address and port
  this.pub = pub || redis.createClient();

  //create a redis socket for subscribing and connect to address and port
  this.sub = sub || redis.createClient();

  //when we receive a message from the subscription socket have us emit a "message" event
  this.sub.on('message', function (channel, message) {
    //TODO update this
    self.emit('message', String(channel + ' ' + message));
  });
}

util.inherits(PubSub, events.EventEmitter);

/**
 * Makes a PubSub
 *
 * @return PubSub
 */

PubSub.make = function (a,b) {
  return new PubSub(a,b);
};

/**
 * Sends a message to the pub sub
 *
 * messages are encoded like so
 *
 * "CHANNEL DATA"
 *
 * e.g.
 *
 * "Nathan {"some":"data"}" currently we URI encode a JSON string for our data
 *
 * @param {string} message
 * @return PubSub
 */

PubSub.prototype.send = function (message) {
  var parts = message.split(' '), channel = parts.shift(), content = parts.shift();
  this.pub.publish(channel, content);
  return this;
};

/**
 * binds the subscriber to a channel
 *
 * @param {string} channel
 * @return PubSub
 */

PubSub.prototype.subscribe = function (channel, cb) {
  this.sub.subscribe(channel, cb || function (err, channel, count) {
		if (err) {
			return console.error(err);
		}
	});
  return this;
};

module.exports = PubSub;
