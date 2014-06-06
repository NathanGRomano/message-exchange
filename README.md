[![Build Status](https://travis-ci.org/NathanGRomano/message-exchange.svg?branch=master)](https://travis-ci.org/NathanGRomano/message-exchange.git)
[![NPM version](https://badge.fury.io/js/message-exchange.svg)](http://badge.fury.io/js/message-exchange)

The goal of this library is to wrap-up **[kue](https://www.npmjs.org/package/kue "Kue")** and **[redis] (https://www.npmjs.org/package/redis "Redis")** and provide a simple interface for building event driven applications.  
At a high-level the library will read messages off of a queue, attempt to handle them, and in some cases publish those events back out onto the pubsub (redis).

# Installation and Environment Setup

Install node.js (See download and install instructions here: http://nodejs.org/).

Install redis (See download and install instructions http://redis.io/topics/quickstart)

Install coffee-script

    > npm install coffee-script -g

Clone this repository

    > git clone git@github.com:NathanGRomano/message-exchange.git

cd into the directory and install the dependencies

    > cd message-exchange
    > npm install && npm shrinkwrap --dev

# Examples

Here is how to create a simple application to handle an event and broadcast it back out.

First we get an exchage instance

```javascript

var events = require('events');
var exchange = require('message-exchange').make();

```

Lets initialize a model and setup a handler for a **quit** event

```javascript

var employeeModel = {hired: new Date()}:

var handler = new events.EventEmitter()
handler.on('quit', function (event) {

  // handle the event
  employeeModel.quit = event.created;

  // let Human Resources know the employee quit 
  exchange.channel('human resources').publish(event);

});

exchange.handler(handler);

```

When we handle a **quit** event we broadcast the messaage to the **human resources** channel.  So let add a listener on that channel so we can relay the information to say a socket.

```javascript

//presume we have declared sockets elsewhere

exchange.channel('human resources').on('message', function (event) {
  sockets.emit('message', event);
});

```

Now lets publish a **quit** event the message queue.  It will be handled by our handler and then broadcast on our channel and finally broadcast to our sockets.

```javascript

exchange.publish({
  actor:'employee', 
  target:'job', 
  action:'quit', 
  created:new Date(), 
  content:'work performed'
});

```

You can put anything you like into an event.  I just like to follow a convention similar to what you saw.
Make sure you have the **required field "action"** in your event.

# API Documentation

## Exchange

This is wheere we publish, handle, and propagate messages.

### #make()

```javascript

var exchange = require('message-exchange').make();

```

### #make(queue:Queue, pubsub:Pubsub, handler:EventEmitter)

```javascript

var messageExchange = require('message-exchange');

var queue = messageExchange.Queue.make();
var pubsub = messageExchange.PubSub.make();
var handler = new EventEmitter();

var exchange = messageExchange.make(queue, pubsub, handler);

```

### #publish(message:Object)

Puts the message onto the `Queue`.

```javascript

var message = {
  actor: 'Me',
  action: 'shout',
  content: 'Hello',
  target: 'You'
};

exchange.publish( message );

```

### #publish(message:Object, channel:String)

Puts the message onto the `PubSub` with the `channel` being `"everyone"`.

```javascript

var message = {
  actor: 'Me',
  action: 'shout',
  content: 'Hello',
  target: 'You'
};

exchange.publish( message, 'everyone' );

```

### #channel(channel:String)

Gets a channel instance, if it doesn't already exist it will subscribe to that
channel.

```javascript 

var channel = exchange.channel('everyone');
channel.on('message', function (message) {
  //do somethign
});

```

### #queue()

Gets the `Queue` instance.

```javascript

var queue = exchange.queue();
queue.send(message);

```

### #queue(queue:Queue)

Sets the `Queue` instance.

```javascript

var kue = require('kue');
var queue = messageExchange.Queue.make(kue.createClient());

exchange.queue(queue);

```

### #pubsub()

Gets the pubsub instance.

```javascript

var pubsub = exchange.pubsub();
pubsub.send(message, 'everyone');

```

### #pubsub(pubsub:PubSub)

Sets the pubsub instance.

```javascript

var redis = require('redis');

var pub = redis.createClient();
var sub = redis.createClient();

var pubsub = messageExchange.PubSub.make(pub, sub);

exchange.pubsub(pubsub);

```

### #handler()

Gets the handler which is an `EventEmitter`.

```javascript

var handler = exchange.handler();
handler.on('some message', function (message, exchange) {
  // do something
  exchange.channel(message.target).publish(message);
});

```

### #handler(handler:EventEmitter)

Sets the handler.

```javascript

var events = require('events');

var handler = new events.EventEmitter;
handler.on('some message', function (message, exchange) {
  // do something
  exchange.channel(message.target).publish(message);
});

exchange.handler(handler);

```

# Running Tests

## Unit Tests

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

To run the tests, just run grunt

    > grunt

# TODO

* Support different queues
* ~~~allow for easier configuration of redis~~~
