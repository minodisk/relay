{Relay} = require '../lib/browser/relay'

afterFunc = ->
  console.log 'afterFunc'
  target2 = {}
  Relay
  .tween(target2, { a: 0 }, { a: 10 }, 1000)
  .complete(->
    console.log 2
  )
  .start()

target = {}
Relay
.tween(target, { a: 0 }, { a: 10 }, 1000)
.complete(->
  console.log 'call after func'
  afterFunc()
)
.start()

#target3 = { a: 0 }
#Relay
#.to(target3, { a: 10 }, 1000)
#.complete(->
#  console.log 3
#)
#.start()
