# Relay

Asynchronous flow-control module for Node.js, RequireJS and browser.

* Relays asynchronous functions serially or parallely.
* Supports deep nesting flow.
* Supports tween and easing methods only for browser.

## Installation at Node.js

    $ npm install relay

## Use in browser

### browser

    <script type="text/javascript" src="relay.js"></script>
    <script>
      var Relay = window.mn.dsk.relay.Relay;
    </script>

### RequireJS

    <script type="text/javascript" src="require.js"></script>
    <script type="text/javascript">
      require(['relay'], function (relay) {
        var Relay = relay.Relay;
      });
    </script>

## API Documentation

### Relay

* **func(function)** - \[static\] Creates function actor.
* **serial(actor\[, actor, ...\])** - \[static\] Creates serial flow with arguments of actor.
* **serial(actors)** - \[static\] Creates serial flow with array of actor.
* **parallel(actor\[, actor, ...\])** - \[static\] Creates parallel flow with arguments of actor.
* **parallel(actors)** - \[static\] Creates parallel flow with array of actor.
* **each(actor, isSerial = false)** - \[static\] Creates iteration actor with arguments.
* **wait(delay)** - \[static\] Creates an actor that contains timer.

### Actor

* **complete(onComplete)** - Sets complete event handler.
* **start(\[arg, ...\])** - Starts the flow.
* **stop()** - Stops the flow.
* **onComplete** - Calls when the flow is finished.

* **global** - The object that is shared in all actors.
    * index: The number of actor that is running now.
    * length: The number of actors in the flow.
* **local** - The object that is shared in single group actor.
    * index: The number of actor that is running now.
    * length: The number of actors in the flow.
* **next(\[arg, ...\])** - Takes the flow into its next actor.
* **skip()** - Skips the flow.
