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


# Running Tests

## Unit Tests

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

To run the tets, just run grunt

    > grunt

# TODO

Still implementing
