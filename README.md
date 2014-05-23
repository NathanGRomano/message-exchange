The goal of this library is to wrap-up kue and redis and provide a simple interface for building event driven applications.  
At a high-level the library will read messages off of a queue, attempt to handle them, and in some cases publish those events back out onto the pubsub (redis).

# Installation and Environment Setup

Install node.js (See download and install instructions here: http://nodejs.org/).

Install redis (See download and install instructions http://redis.io/topics/quickstart)

Clone this repository

    > git clone git@github.com:NathanGRomano/message-exchange.git

cd into the app directory and install the dependencies

    > npm install && npm shrinkwrap --dev

# Examples

Here is how to create a simple application to handle an event and broadcast it back out.

First we get an exchage instance

```javascript

var exchange = require('message-exchange').make();

```

Lets initialize a model and setup a handler for a **quit** event

```javascript

var employeeModel = {hired: new Date()}:

exchange.handler.on('quit', function (event) {

  // handle the event
  employeeModel.quit = event.created;

  // let Human Resources know the employee quit 
  exchange.channel('human resources').publish(event);

});

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

exchange.publish({actor:'employee', target:'job', action:'quit', created:new Date(), content:'work performed'});

```

# Running Tests

## Unit Tests

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

To run the tets, just run grunt

    > grunt

# TODO

Still implementing
