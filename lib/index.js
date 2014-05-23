exports.Exchange = require('./exchange');
exports.Channel = require('./channel');
exports.Queue = require('./queue');
exports.PubSub = require('./pubsub');

exports.make = function (a,b,c) {
  return Exchange.make(a,b,c);
};
