var util = require('util')
  , events = require('events')
  , kue = require('kue')
  ;

/*
 * We use a queue to process events when we must handle the events sequentially
 */

function Queue (q) {
  events.EventEmitter.call(this);
  var self = this;

  this.q = q && q.process ? q : kue.createQueue();
  this.q.process('message', function (message, done) {
    self.emit('message', message);
    done();
  });
}

util.inherits(Queue, events.EventEmitter);

/**
 * Makes a Queue
 *
 * @return Queue
 */

Queue.make = function (q) {
  return new Queue(q);
};

/**
 * Sends a message to the queue
 *
 * @param object message
 * @return Queue
 */

Queue.prototype.send = function (message) {
  this.q.create('message', message).save();
  return this;
};

module.exports = Queue;

kue.app.listen(3001);
