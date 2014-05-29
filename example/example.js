var messageExchange = require('./..').make();

messageExchange.handler.on('say', function (message, exchange) {
  exchange.channel(message.target).publish(message);
});

messageExchange.channel('me').on('message', function (message) {
  console.log('received: ' + JSON.stringify(message));
  process.exit();
});

messageExchange.publish({actor: 'you', target: 'me', action: 'say', content: ['Hello, World'], created:new Date()});

