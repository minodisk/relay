fs = require 'fs'
{ Relay } = require '../lib/browser/relay'

getTime = ->
  new Date().getTime()

module.exports =

'test phase':
  'func sync': (test)->
    Relay.func(->
      test.strictEqual @local, undefined
      test.strictEqual @global.index, undefined
      @next()
    ).complete(->
      test.strictEqual @local, undefined
      test.strictEqual @global.index, undefined
      test.done()
    ).start()
  'func(async)': (test)->
    Relay.func(
      ->
        test.strictEqual @local, undefined
        test.strictEqual @global.index, undefined
        setTimeout @next, 10
    ).complete(
      ->
        test.strictEqual @local, undefined
        test.strictEqual @global.index, undefined
        test.done()
    ).start()
  wait: (test)->
    Relay.wait(10).complete(
      ->
        test.strictEqual @local, undefined
        test.strictEqual @global.index, undefined
        test.done()
    ).start()
  tween: (test)->
    target = {}
    Relay.tween(target, { a: 0 }, { a: 10 }, 10).complete(
      ->
        test.strictEqual @local, undefined
        test.strictEqual @global.index, undefined
        test.done()
    ).start()
  to: (test)->
    target = { a: 0 }
    Relay.to(target, { a: 10 }, 10).complete(
      ->
        test.strictEqual @local, undefined
        test.strictEqual @global.index, undefined
        test.done()
    ).start()

  serial:
    'func(sync)': (test)->
      Relay.serial(
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            @next()
        )
        Relay.func(->
            test.strictEqual @local.index, 1
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 1
            @next()
        )
        Relay.func(->
            test.strictEqual @local.index, 2
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 2
            @next()
        )
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.done()
      ).start()
    'func(async)': (test)->
      Relay.serial(
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
        Relay.func(->
            test.strictEqual @local.index, 1
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 1
            setTimeout @next, 10
        )
        Relay.func(->
            test.strictEqual @local.index, 2
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 2
            setTimeout @next, 10
        )
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.done()
      ).start()
    wait: (test)->
      Relay.serial(
        Relay.wait(10)
        Relay.wait(10)
        Relay.wait(10)
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.done()
      ).start()
    mixed: (test)->
      target = {}
      Relay.serial(
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
        Relay.wait(10)
        Relay.func(->
            test.strictEqual @local.index, 2
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 2
            setTimeout @next, 10
        )
        Relay.func(->
            test.strictEqual @local.index, 3
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 3
            @next()
        )
        Relay.tween(target, {a: 0}, {a: 10}, 10)
        Relay.func(->
            test.strictEqual @local.index, 5
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 5
            @next()
        )
        Relay.to(target, {a: 20}, 10)
        Relay.func(->
            test.strictEqual @local.index, 7
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 7
            @next()
        )
      ).complete(
        ->
          test.strictEqual @local.index, 8
          test.strictEqual @local.length, 8
          test.strictEqual @global.index, 8
          test.done()
      ).start()

  parallel:
    'func(sync)': (test)->
      Relay.parallel(
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            @next()
        )
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            @next()
        )
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            @next()
        )
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.done()
      ).start()
    func: (test)->
      Relay.parallel(
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.done()
      ).start()
    wait: (test)->
      Relay.parallel(
        Relay.wait(10)
        Relay.wait(10)
        Relay.wait(10)
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.done()
      ).start()
    mixed: (test)->
      target = {}
      Relay.parallel(
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
        Relay.wait(10)
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
        Relay.tween(target, {a: 0}, {a: 10}, 10)
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
        Relay.to(target, {a: 20}, 10)
        Relay.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
      ).complete(
        ->
          test.strictEqual @local.index, 8
          test.strictEqual @local.length, 8
          test.strictEqual @global.index, 8
          test.done()
      ).start()

'test nesting':
  serial:
    serial: (test)->
      counter = 0
      Relay.serial(
        Relay.serial(
          Relay.func(->
              test.strictEqual counter++, 0
              @next()
          )
          Relay.func(->
              test.strictEqual counter++, 1
              @next()
          )
        )
        Relay.serial(
          Relay.func(->
              test.strictEqual counter++, 2
              @next()
          )
          Relay.func(->
              test.strictEqual counter++, 3
              @next()
          )
        )
        Relay.serial(
          Relay.func(->
              test.strictEqual counter++, 4
              @next()
          )
          Relay.func(->
              test.strictEqual counter++, 5
              @next()
          )
        )
      ).complete(
        ->
          test.strictEqual counter, 6
          test.done()
      ).start()
    parallel: (test)->
      counter = 0
      Relay.serial(
        Relay.parallel(
          Relay.func(->
              test.strictEqual counter++, 0
              @next()
          )
          Relay.func(->
              test.strictEqual counter++, 1
              @next()
          )
        )
        Relay.parallel(
          Relay.func(->
              test.strictEqual counter++, 2
              @next()
          )
          Relay.func(->
              test.strictEqual counter++, 3
              @next()
          )
        )
        Relay.parallel(
          Relay.func(->
              test.strictEqual counter++, 4
              @next()
          )
          Relay.func(->
              test.strictEqual counter++, 5
              @next()
          )
        )
      ).complete(
        ->
          test.strictEqual counter, 6
          test.done()
      ).start()

'test shared params':
  sync: (test)->
    Relay.func(
      ->
        @global.a = 'foo'
        @next()
    ).complete(
      ->
        test.strictEqual @global.a, 'foo'
        test.done()
    ).start()
  func: (test)->
    Relay.func(
      ->
        @global.a = 'foo'
        setTimeout @next, 10
    ).complete(
      ->
        test.strictEqual @global.a, 'foo'
        test.done()
    ).start()

  serial:
    sync: (test)->
      Relay.serial(
        Relay.func(->
            @local.str = 'foo'
            @global.str = 'foo'
            @next()
        )
        Relay.func(->
            @local.str += 'bar'
            @global.str += 'bar'
            @next()
        )
        Relay.func(->
            @local.str += 'baz'
            @global.str += 'baz'
            @next()
        )
      ).complete(
        ->
          test.strictEqual @local.str, 'foobarbaz'
          test.strictEqual @global.str, 'foobarbaz'
          test.done()
      ).start()
    serial: (test)->
      Relay.serial(
        Relay.func(->
            @local.str = 'foo'
            @global.str = 'foo'
            @next()
        )
        Relay.serial(
          Relay.func(->
              test.strictEqual @local.str, undefined
              @local.str = 'bar'
              @global.str += 'bar'
              @next()
          )
          Relay.func(->
              @local.str += 'baz'
              @global.str += 'baz'
              test.strictEqual @local.str, 'barbaz'
              @next()
          )
        )
        Relay.func(->
            @local.str += 'qux'
            @global.str += 'qux'
            @next()
        )
      ).complete(
        ->
          test.strictEqual @local.str, 'fooqux'
          test.strictEqual @global.str, 'foobarbazqux'
          test.done()
      ).start()
    parallel: (test)->
      Relay.serial(
        Relay.func(->
            @local.num = 2
            @global.num = 2
            @next()
        )
        Relay.parallel(
          Relay.func(->
              @global.num *= 3
              @next()
          )
          Relay.func(->
              @global.num *= 4
              @next()
          )
        )
        Relay.func(->
            @local.num += 1
            @global.num += 1
            @next()
        )
      ).complete(
        ->
          test.strictEqual @local.num, 3
          test.strictEqual @global.num, 25
          test.done()
      ).start()

  parallel:
    sync: (test)->
      Relay.parallel(
        Relay.func(->
            @global.num = 1
            @next()
        )
        Relay.func(->
            @global.num += 2
            @next()
        )
        Relay.func(->
            @global.num += 3
            @next()
        )
      ).complete(
        ->
          test.strictEqual @global.num, 6
          test.done()
      ).start()
    serial: (test)->
      Relay.parallel(
        Relay.func(->
            @global.num = 1
            @next()
        )
        Relay.serial(
          Relay.func(->
              @global.num += 2
              @next()
          )
          Relay.func(->
              @global.num += 3
              @next()
          )
        )
      ).complete(
        ->
          test.strictEqual @global.num, 6
          test.done()
      ).start()
    parallel: (test)->
      Relay.parallel(
        Relay.func(->
            @global.num = 1
            @next()
        )
        Relay.parallel(
          Relay.func(->
              @global.num += 2
              @next()
          )
          Relay.func(->
              @global.num += 3
              @next()
          )
        )
      ).complete(
        ->
          test.strictEqual @global.num, 6
          test.done()
      ).start()

'test arguments':
  func: (test)->
    Relay.func((a, b)->
      test.strictEqual a, 'a'
      test.strictEqual b, 'b'
      @next a, b
    ).complete((a, b)->
      test.strictEqual a, 'a'
      test.strictEqual b, 'b'
      test.done()
    ).start 'a', 'b'
  file: (test)->
    Relay.func(->
      fs.readFile "#{__dirname}/data/numbers.json", 'utf8', @next
    ).complete((err, data)->
      numbers = JSON.parse data
      test.deepEqual numbers, [0, 1, 2, 3, 4]
      test.done()
    ).start()

  serial:
    func: (test)->
      Relay.serial(
        Relay.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'c', 'd'
        )
        Relay.func((c, d)->
          test.strictEqual c, 'c'
          test.strictEqual d, 'd'
          @next 'e', 'f'
        )
      ).complete((e, f)->
        test.strictEqual e, 'e'
        test.strictEqual f, 'f'
        test.done()
      ).start 'a', 'b'
    serial: (test)->
      Relay.serial(
        Relay.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'c', 'd'
        )
        Relay.serial(
          Relay.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
          )
          Relay.func((e, f)->
            test.strictEqual e, 'e'
            test.strictEqual f, 'f'
            @next 'g', 'h'
          )
        )
      ).complete((g, h)->
        test.strictEqual g, 'g'
        test.strictEqual h, 'h'
        test.done()
      ).start 'a', 'b'
    serial: (test)->
      Relay.serial(
        Relay.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'c', 'd'
        )
        Relay.parallel(
          Relay.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
          )
          Relay.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'g', 'h'
          )
        )
      ).complete((results0, results1)->
        test.deepEqual results0, ['e', 'f']
        test.deepEqual results1, ['g', 'h']
        test.done()
      ).start 'a', 'b'
    complex: (test)->
      Relay.serial(
        Relay.serial(
          Relay.func((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'c', 'd'
          )
          Relay.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
          )
        )
        Relay.func((e, f)->
          test.strictEqual e, 'e'
          test.strictEqual f, 'f'
          @next 'g', 'h'
        )
      ).complete(->
        test.done()
      ).start 'a', 'b'

  parallel:
    func: (test)->
      Relay.parallel(
        Relay.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'c', 'd'
        )
        Relay.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'e', 'f'
        )
      ).complete((results0, results1)->
        test.deepEqual results0, ['c', 'd']
        test.deepEqual results1, ['e', 'f']
        test.done()
      ).start 'a', 'b'
    serial: (test)->
      Relay.parallel(
        Relay.serial(
          Relay.func((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'c', 'd'
          )
          Relay.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
          )
        )
        Relay.serial(
          Relay.func((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'g', 'h'
          )
          Relay.func((g, h)->
            test.strictEqual g, 'g'
            test.strictEqual h, 'h'
            @next 'i', 'j'
          )
        )
      ).complete((results0, results1)->
        test.deepEqual results0, ['e', 'f']
        test.deepEqual results1, ['i', 'j']
        test.done()
      ).start 'a', 'b'

  clone:
    func: (test)->
      src = Relay.func(->
        setTimeout =>
          @next()
        , 100
      )
      dst = src.clone()
      src.complete(->
        test.strictEqual dst.onComplete, undefined
        test.done()
      ).start()
    serial: (test)->
      src = Relay.serial(
        Relay.func(->
          setTimeout =>
            @next()
          , 100
        )
      )
      dst = src.clone()
      src.complete(->
        test.strictEqual dst.onComplete, undefined
        test.strictEqual dst.local, undefined
        test.strictEqual dst.global, undefined
        test.done()
      ).start()
    parallel: (test)->
      src = Relay.func(->
        setTimeout =>
          @next()
        , 100
      )
      dst = src.clone()
      Relay.parallel(src, dst).complete(->
        test.done()
      ).start()
    'parallel serial': (test)->
      src = Relay.serial(
        Relay.func(->
          setTimeout =>
            @next()
          , 100
        )
        Relay.func(->
          setTimeout =>
            @next()
          , 100
        )
      )
      dst = src.clone()
      Relay.parallel(src, dst).complete(->
        test.done()
      ).start()

  'each (runs parallely)':
    func: (test)->
      counter = 0
      array = ['a', 'b']
      time = getTime()
      Relay.each(
        Relay.func((elem, i, arr)->
          test.strictEqual elem, array[counter]
          test.strictEqual i, counter++
          test.deepEqual arr, array
          setTimeout =>
            @next elem, elem + 'c'
          , 100
        )
      ).complete((results0, results1)->
        console.log getTime() - time, 'will be near 100'
        test.deepEqual results0, ['a', 'ac']
        test.deepEqual results1, ['b', 'bc']
        test.done()
      ).start array
    serial: (test)->
      counter = 0
      array = ['a', 'b']
      time = getTime()
      Relay.each(
        Relay.serial(
          Relay.func((elem, i, arr)->
            test.strictEqual elem, array[counter]
            test.strictEqual i, counter++
            test.deepEqual arr, array
            setTimeout =>
              @next elem, elem + 'c'
            , 100
          )
          Relay.func((str0, str1)->
            setTimeout =>
              @next str0, str1, str1 + 'd'
            , 200
          )
        )
      ).complete((results0, results1)->
        console.log getTime() - time, 'will be near 300'
        test.deepEqual results0, ['a', 'ac', 'acd']
        test.deepEqual results1, ['b', 'bc', 'bcd']
        test.done()
      ).start array
    parallel: (test)->
      counter = 0
      array = ['a', 'b']
      time = getTime()
      Relay.each(
        Relay.parallel(
          Relay.func((elem, i, arr)->
            test.strictEqual elem, array[counter]
            test.strictEqual i, counter
            test.deepEqual arr, array
            setTimeout =>
              @next elem, elem + 'c'
            , 100
          )
          Relay.func((elem, i, arr)->
            test.strictEqual elem, array[counter]
            test.strictEqual i, counter++
            test.deepEqual arr, array
            setTimeout =>
              @next elem, elem + 'd'
            , 200
          )
        )
      ).complete((results0, results1)->
        console.log getTime() - time, 'will be near 200'
        test.deepEqual results0, [['a', 'ac'], ['a', 'ad']]
        test.deepEqual results1, [['b', 'bc'], ['b', 'bd']]
        test.done()
      ).start array

  'each (runs serially)':
    func: (test)->
      counter = 0
      array = ['a', 'b']
      time = getTime()
      Relay.each(
        Relay.func((elem, i, arr)->
          test.strictEqual elem, array[counter]
          test.strictEqual i, counter++
          test.deepEqual arr, array
          setTimeout =>
            @next elem, elem + 'c'
          , 100
        ), true
      ).complete((results0, results1)->
        console.log getTime() - time, 'will be near 200'
        test.deepEqual results0, ['a', 'ac']
        test.deepEqual results1, ['b', 'bc']
        test.done()
      ).start array
    serial: (test)->
      counter = 0
      array = ['a', 'b']
      time = getTime()
      Relay.each(
        Relay.serial(
          Relay.func((elem, i, arr)->
            test.strictEqual elem, array[counter]
            test.strictEqual i, counter++
            test.deepEqual arr, array
            setTimeout =>
              @next elem, elem + 'c'
            , 100
          )
          Relay.func((str0, str1)->
            setTimeout =>
              @next str0, str1, str1 + 'd'
            , 200
          )
        ), true
      ).complete((results0, results1)->
        console.log getTime() - time, 'will be near 600'
        test.deepEqual results0, ['a', 'ac', 'acd']
        test.deepEqual results1, ['b', 'bc', 'bcd']
        test.done()
      ).start array
    parallel: (test)->
      counter = 0
      array = ['a', 'b']
      time = getTime()
      Relay.each(
        Relay.parallel(
          Relay.func((elem, i, arr)->
            test.strictEqual elem, array[counter]
            test.strictEqual i, counter
            test.deepEqual arr, array
            setTimeout =>
              @next elem, elem + 'c'
            , 100
          )
          Relay.func((elem, i, arr)->
            test.strictEqual elem, array[counter]
            test.strictEqual i, counter++
            test.deepEqual arr, array
            setTimeout =>
              @next elem, elem + 'd'
            , 200
          )
        ), true
      ).complete((results0, results1)->
        console.log getTime() - time, 'will be near 400'
        test.deepEqual results0, [['a', 'ac'], ['a', 'ad']]
        test.deepEqual results1, [['b', 'bc'], ['b', 'bd']]
        test.done()
      ).start array

'test skip':
  serial: (test)->
    Relay.serial(
      Relay.func(->
          @global.str = 'a'
          @next()
      )
      Relay.serial(
        Relay.func(->
            @global.str += 'b'
            @next()
        )
        Relay.func(->
            if true
              @skip()
            else
              @global.str += 'c'
              @next()
        )
        Relay.func(->
            test.ok false, 'expect to be skipped'
            @global.str += 'd'
            @next()
        )
      )
      Relay.func(->
          @global.str += 'e'
          @next()
      )
    ).complete(
      ->
        test.strictEqual @global.str, 'abe'
        test.done()
    ).start()
  parallel: (test)->
    Relay.serial(
      Relay.func(->
          @global.value = 0
          @next()
      )
      Relay.parallel(
        Relay.func(->
            @global.value += 1
            @next()
        )
        Relay.func(->
            if true
              @skip()
            else
              @global.value += 2
              @next()
        )
        Relay.func(->
            test.ok false, 'expect to be skipped'
            @global.value += 3
            @next()
        )
      )
      Relay.func(->
          @global.value *= 10
          @next()
      )
    ).complete(
      ->
        test.strictEqual @global.value, 10
        test.done()
    ).start()

