# JuncJS

Asynchronous flow-control module for Node.js, RequireJS and browser.
Supports tween and easing methods for browser only.

## Installation

### Node.js

    $ npm install junc

### RequireJS

    <script type="text/javascript" src="require.js"></script>
    <script type="text/javascript">
      require(['junc'], function (junc) {
        var Junc = junc.Junc;
      });
    </script>

### browser

    <script type="text/javascript" src="junc.js"></script>
    <script>
      var Junc = window.mn.dsk.junc.Junc;
    </script>

## API Documentation

### Class Methods
* **serial(actor\[, actor, ...\])** - \[static\] Creates serial flow with arguments of actor.
* **serial(actors)** - \[static\] Creates serial flow with array of actor.
* **parallel(actor\[, actor, ...\])** - \[static\] Creates parallel flow with arguments of actor.
* **parallel(actors)** - \[static\] Creates parallel flow with array of actor.
* **each(actor, isSerial = false)** - \[static\] Creates iteration actor with arguments.
* **wait(delay)** - \[static\] Creates an actor that contains timer.

### Member Properties
* **global** - The object that is shared in all actors.
  index: The number of actor that is running now.
  length: The number of actors in the flow.
* **local** - The object that is shared in single group actor.
  index: The number of actor that is running now.
  length: The number of actors in the flow.

### Member Methods
* **complete(onComplete)** - Sets complete event handler.
* **start()** - Starts the flow.
* **stop()** - Stops the flow.
* **next()** - Takes the flow into its next actor.
* **skip()** - Skips the flow.

### Event Handlers
* **onComplete** - Calls when the flow is finished.

