fs = require 'fs'
Junc = require '../lib/browser/junc'

getTime = ->
  new Date().getTime()

module.exports =

'test phase':
  'func sync': (test)->
    Junc.func(->
      test.strictEqual @local, undefined
      test.strictEqual @global.index, undefined
      @next()
    ).complete(->
      test.strictEqual @local, undefined
      test.strictEqual @global.index, undefined
      test.done()
    ).start()
  'func(async)': (test)->
    Junc.func(
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
    Junc.wait(10).complete(
      ->
        test.strictEqual @local, undefined
        test.strictEqual @global.index, undefined
        test.done()
    ).start()
  tween: (test)->
    target = {}
    Junc.tween(target, { a: 0 }, { a: 10 }, 10).complete(
      ->
        test.strictEqual @local, undefined
        test.strictEqual @global.index, undefined
        test.done()
    ).start()
  to: (test)->
    target = { a: 0 }
    Junc.to(target, { a: 10 }, 10).complete(
      ->
        test.strictEqual @local, undefined
        test.strictEqual @global.index, undefined
        test.done()
    ).start()

  serial:
    'func(sync)': (test)->
      Junc.serial(
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            @next()
        )
        Junc.func(->
            test.strictEqual @local.index, 1
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 1
            @next()
        )
        Junc.func(->
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
      Junc.serial(
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
        Junc.func(->
            test.strictEqual @local.index, 1
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 1
            setTimeout @next, 10
        )
        Junc.func(->
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
      Junc.serial(
        Junc.wait(10)
        Junc.wait(10)
        Junc.wait(10)
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.done()
      ).start()
    mixed: (test)->
      target = {}
      Junc.serial(
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
        Junc.wait(10)
        Junc.func(->
            test.strictEqual @local.index, 2
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 2
            setTimeout @next, 10
        )
        Junc.func(->
            test.strictEqual @local.index, 3
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 3
            @next()
        )
        Junc.tween(target, {a: 0}, {a: 10}, 10)
        Junc.func(->
            test.strictEqual @local.index, 5
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 5
            @next()
        )
        Junc.to(target, {a: 20}, 10)
        Junc.func(->
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
      Junc.parallel(
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            @next()
        )
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            @next()
        )
        Junc.func(->
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
      Junc.parallel(
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
        Junc.func(->
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
      Junc.parallel(
        Junc.wait(10)
        Junc.wait(10)
        Junc.wait(10)
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.done()
      ).start()
    mixed: (test)->
      target = {}
      Junc.parallel(
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
        Junc.wait(10)
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            setTimeout @next, 10
        )
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
        Junc.tween(target, {a: 0}, {a: 10}, 10)
        Junc.func(->
            test.strictEqual @local.index, 0
            test.strictEqual @local.length, 8
            test.strictEqual @global.index, 0
            @next()
        )
        Junc.to(target, {a: 20}, 10)
        Junc.func(->
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

###
  repeat:
    sync: (test)->
      counter = 0
      Junc.repeat(
        Junc.func(->
            test.strictEqual @local.index, counter
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, counter
            test.strictEqual @repeat.index, counter++, 'repeat.index'
            test.strictEqual @repeat.length, 3
            @next()
        ), 3
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.strictEqual @repeat.index, 3
          test.strictEqual @repeat.length, 3
          test.done()
      ).start()
    func: (test)->
      counter = 0
      Junc.repeat(
        Junc.func(->
            test.strictEqual @local.index, counter
            test.strictEqual @local.length, 3
            test.strictEqual @global.index, counter
            test.strictEqual @repeat.index, counter++
            test.strictEqual @repeat.length, 3
            setTimeout @next, 10
        ), 3
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.strictEqual @repeat.index, 3
          test.strictEqual @repeat.length, 3
          test.done()
      ).start()
    wait: (test)->
      Junc.repeat(
        Junc.wait(10), 3
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.strictEqual @repeat.index, 3
          test.strictEqual @repeat.length, 3
          test.done()
      ).start()
    tween: (test)->
      target = {}
      Junc.repeat(
        Junc.tween(target, { a: 0 }, { a: 10 }, 10), 3
      ).complete(
        ->
          test.strictEqual @local.index, 3
          test.strictEqual @local.length, 3
          test.strictEqual @global.index, 3
          test.strictEqual @repeat.index, 3
          test.strictEqual @repeat.length, 3
          test.done()
      ).start()
    serial: (test)->
      Junc.repeat(
        Junc.serial(
          Junc.func(->
              test.strictEqual @local.index, 0
              test.strictEqual @local.length, 3
              test.strictEqual @global.index, 3 * @repeat.index + 0
              test.strictEqual @repeat.length, 5
              @next()
          )
          Junc.func(->
              test.strictEqual @local.index, 1
              test.strictEqual @local.length, 3
              test.strictEqual @global.index, 3 * @repeat.index + 1
              test.strictEqual @repeat.length, 5
              @next()
          )
          Junc.func(->
              test.strictEqual @local.index, 2
              test.strictEqual @local.length, 3
              test.strictEqual @global.index, 3 * @repeat.index + 2
              test.strictEqual @repeat.length, 5
              @next()
          )
        ), 5
      ).complete(
        ->
          test.strictEqual @local.index, 5
          test.strictEqual @local.length, 5
          test.strictEqual @global.index, 15
          test.done()
      ).start()

    parallel: (test)->
      Junc.repeat(
        Junc.parallel(
          Junc.func(->
              test.strictEqual @local.index, 0
              test.strictEqual @local.length, 3
              test.strictEqual @global.index, 3 * @repeat.index
              @next()
          )
          Junc.func(->
              test.strictEqual @local.index, 0
              test.strictEqual @local.length, 3
              test.strictEqual @global.index, 3 * @repeat.index
              @next()
          )
          Junc.func(->
              test.strictEqual @local.index, 0
              test.strictEqual @local.length, 3
              test.strictEqual @global.index, 3 * @repeat.index
              @next()
          )
        ), 5
      ).complete(
        ->
          test.strictEqual @local.index, 5
          test.strictEqual @local.length, 5
          test.strictEqual @global.index, 15
          test.done()
      ).start()
###

'test nesting':
  serial:
    serial: (test)->
      counter = 0
      Junc.serial(
        Junc.serial(
          Junc.func(->
              test.strictEqual counter++, 0
              @next()
          )
          Junc.func(->
              test.strictEqual counter++, 1
              @next()
          )
        )
        Junc.serial(
          Junc.func(->
              test.strictEqual counter++, 2
              @next()
          )
          Junc.func(->
              test.strictEqual counter++, 3
              @next()
          )
        )
        Junc.serial(
          Junc.func(->
              test.strictEqual counter++, 4
              @next()
          )
          Junc.func(->
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
      Junc.serial(
        Junc.parallel(
          Junc.func(->
              test.strictEqual counter++, 0
              @next()
          )
          Junc.func(->
              test.strictEqual counter++, 1
              @next()
          )
        )
        Junc.parallel(
          Junc.func(->
              test.strictEqual counter++, 2
              @next()
          )
          Junc.func(->
              test.strictEqual counter++, 3
              @next()
          )
        )
        Junc.parallel(
          Junc.func(->
              test.strictEqual counter++, 4
              @next()
          )
          Junc.func(->
              test.strictEqual counter++, 5
              @next()
          )
        )
      ).complete(
        ->
          test.strictEqual counter, 6
          test.done()
      ).start()
    repeat: (test)->
      counter = 0
      Junc.serial(
        Junc.repeat(
          Junc.func(->
              test.strictEqual counter++, @local.index
              @next()
          ), 3
        )
        Junc.func(->
            test.strictEqual counter++, 3
            @next()
        )
        Junc.repeat(
          Junc.func(->
              test.strictEqual counter++, 4 + @local.index
              @next()
          ), 3
        )
      ).complete(
        ->
          test.strictEqual counter, 7
          test.done()
      ).start()
    deep: (test)->
      counter = 0
      Junc.serial(
        Junc.func(->
            counter++
            @next()
        )
        Junc.wait(10)
        Junc.repeat(
          Junc.parallel(
            Junc.func(->
                counter++
                @next()
            )
            Junc.wait(10)
            Junc.serial(
              Junc.func(->
                  counter++
                  @next()
              )
              Junc.wait(10)
              Junc.repeat(
                Junc.func(->
                    counter++
                    @next()
                ), 3
              )
            )
            Junc.wait(10)
            Junc.func(->
                counter++
                @next()
            )
          ), 3
        )
        Junc.wait(10)
        Junc.func(->
            counter++
            @next()
        )
      ).complete(
        ->
          test.strictEqual counter, 20
          test.done()
      ).start()

'test shared params':
  sync: (test)->
    Junc.func(
      ->
        @global.a = 'foo'
        @next()
    ).complete(
      ->
        test.strictEqual @global.a, 'foo'
        test.done()
    ).start()
  func: (test)->
    Junc.func(
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
      Junc.serial(
        Junc.func(->
            @local.str = 'foo'
            @global.str = 'foo'
            @next()
        )
        Junc.func(->
            @local.str += 'bar'
            @global.str += 'bar'
            @next()
        )
        Junc.func(->
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
      Junc.serial(
        Junc.func(->
            @local.str = 'foo'
            @global.str = 'foo'
            @next()
        )
        Junc.serial(
          Junc.func(->
              test.strictEqual @local.str, undefined
              @local.str = 'bar'
              @global.str += 'bar'
              @next()
          )
          Junc.func(->
              @local.str += 'baz'
              @global.str += 'baz'
              test.strictEqual @local.str, 'barbaz'
              @next()
          )
        )
        Junc.func(->
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
      Junc.serial(
        Junc.func(->
            @local.num = 2
            @global.num = 2
            @next()
        )
        Junc.parallel(
          Junc.func(->
              @global.num *= 3
              @next()
          )
          Junc.func(->
              @global.num *= 4
              @next()
          )
        )
        Junc.func(->
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

    ###
    deep: (test)->
      Junc.serial(
        Junc.func(->
            @local.a = 10
            @global.a = 10
            @global.b = 'foo'
            @global.c = { num: 30, str: 'bar' }
            @global.d = [1, 'baz']
            @next()
        )
        Junc.wait(10)
        Junc.repeat(
          Junc.parallel(
            Junc.func(->
                @global.a += 1
                @global.b += '-'
                @global.c.num -= 2
                @global.c.str += '='
                @global.d[0] *= 2
                @global.d[1] += '_'
                @next()
            )
            Junc.wait(10)
            Junc.serial(
              Junc.func(->
                  test.strictEqual @local.a, undefined
                  @local.a = 2
                  @global.a *= 2
                  @global.c.num /= 2
                  @global.d[0] *= 2
                  @next()
              )
              Junc.wait(10)
              Junc.repeat(
                Junc.func(->
                    if @repeat.index is 0
                      @local.a = 2
                    else
                      @local.a *= 2
                    if @repeat.index is 2
                      test.strictEqual @local.a, 8
                    @global.b += '-'
                    @global.c.str += '='
                    @global.d[1] += '_'
                    @next()
                ), 3
              )
            )
            Junc.wait(10)
            Junc.func(->
                @global.a += 4
                @global.b += '-'
                @global.c.num += 4
                @global.c.str += '='
                @global.d[0] *= 2
                @global.d[1] += '_'
                @next()
            )
          ), 3
        )
        Junc.wait(10)
        Junc.func(->
            @local.a += 7
            @global.a += 7
            @global.b += 'foo'
            @global.c.num += 1
            @global.c.str += 'bar'
            @global.d[0] += 2
            @global.d[1] += 'baz'
            @next()
        )
      ).complete(
        ->
          test.strictEqual @local.a, 17
          test.strictEqual @global.a, 129
          test.strictEqual @global.b, 'foo---------------foo'
          test.deepEqual @global.c, { num: 10, str: 'bar===============bar'}
          test.deepEqual @global.d, [514, 'baz_______________baz']
          test.done()
      ).start()
###

  parallel:
    sync: (test)->
      Junc.parallel(
        Junc.func(->
            @global.num = 1
            @next()
        )
        Junc.func(->
            @global.num += 2
            @next()
        )
        Junc.func(->
            @global.num += 3
            @next()
        )
      ).complete(
        ->
          test.strictEqual @global.num, 6
          test.done()
      ).start()
    serial: (test)->
      Junc.parallel(
        Junc.func(->
            @global.num = 1
            @next()
        )
        Junc.serial(
          Junc.func(->
              @global.num += 2
              @next()
          )
          Junc.func(->
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
      Junc.parallel(
        Junc.func(->
            @global.num = 1
            @next()
        )
        Junc.parallel(
          Junc.func(->
              @global.num += 2
              @next()
          )
          Junc.func(->
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
    Junc.func((a, b)->
      test.strictEqual a, 'a'
      test.strictEqual b, 'b'
      @next a, b
    ).complete((a, b)->
      test.strictEqual a, 'a'
      test.strictEqual b, 'b'
      test.done()
    ).start 'a', 'b'
  file: (test)->
    Junc.func(->
      fs.readFile "#{__dirname}/data/numbers.json", 'utf8', @next
    ).complete((err, data)->
      numbers = JSON.parse data
      test.deepEqual numbers, [0, 1, 2, 3, 4]
      test.done()
    ).start()

  serial:
    func: (test)->
      Junc.serial(
        Junc.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'c', 'd'
        )
        Junc.func((c, d)->
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
      Junc.serial(
        Junc.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'c', 'd'
        )
        Junc.serial(
          Junc.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
          )
          Junc.func((e, f)->
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
      Junc.serial(
        Junc.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'c', 'd'
        )
        Junc.parallel(
          Junc.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
          )
          Junc.func((c, d)->
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
      Junc.serial(
        Junc.serial(
          Junc.func((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'c', 'd'
          )
          Junc.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
          )
        )
        Junc.func((e, f)->
          test.strictEqual e, 'e'
          test.strictEqual f, 'f'
          @next 'g', 'h'
        )
      ).complete(->
        test.done()
      ).start 'a', 'b'

  parallel:
    func: (test)->
      Junc.parallel(
        Junc.func((a, b)->
          test.strictEqual a, 'a'
          test.strictEqual b, 'b'
          @next 'c', 'd'
        )
        Junc.func((a, b)->
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
      Junc.parallel(
        Junc.serial(
          Junc.func((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'c', 'd'
          )
          Junc.func((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
          )
        )
        Junc.serial(
          Junc.func((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'g', 'h'
          )
          Junc.func((g, h)->
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
      src = Junc.func(->
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
      src = Junc.serial(
        Junc.func(->
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
      src = Junc.func(->
        setTimeout =>
          @next()
        , 100
      )
      dst = src.clone()
      Junc.parallel(src, dst).complete(->
        test.done()
      ).start()
    'parallel serial': (test)->
      src = Junc.serial(
        Junc.func(->
          setTimeout =>
            @next()
          , 100
        )
        Junc.func(->
          setTimeout =>
            @next()
          , 100
        )
      )
      dst = src.clone()
      Junc.parallel(src, dst).complete(->
        test.done()
      ).start()

  'parallel each':
    func: (test)->
      counter = 0
      array = ['a', 'b']
      time = getTime()
      Junc.each(
        Junc.func((elem)->
          test.strictEqual elem, array[counter++]
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
      Junc.each(
        Junc.serial(
          Junc.func((elem)->
            @local[elem] = true
            test.strictEqual elem, array[counter++]
            setTimeout =>
              @next elem, elem + 'c'
            , 100
          )
          Junc.func((str0, str1)->
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
      Junc.each(
        Junc.parallel(
          Junc.func((elem, i, arr)->
            setTimeout =>
              @next elem, elem + 'c'
            , 100
          )
          Junc.func((elem, i, arr)->
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
###
  'serial each':
    func: (test)->
      counter = 0
      array = ['a', 'b']
      time = getTime()
      Junc.each(
        Junc.func((elem, i, arr)->
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
      Junc.each(
        Junc.serial(
          Junc.func((elem, i, arr)->
            test.strictEqual elem, array[counter]
            test.strictEqual i, counter++
            test.deepEqual arr, array
            setTimeout =>
              @next elem, elem + 'c'
            , 100
          )
          Junc.func((str0, str1)->
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
      Junc.each(
        Junc.parallel(
          Junc.func((elem, i, arr)->
            setTimeout =>
              @next elem, elem + 'c'
            , 100
          )
          Junc.func((elem, i, arr)->
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

  parallels:
    func: (test)->
      counter = 0
      array = ['a', 'b']
      time = new Date().getTime()
      Junc.parallels(
        Junc.func((elem, i, arr)->
          test.strictEqual elem, array[counter]
          test.strictEqual i, counter
          test.deepEqual arr, array
          setTimeout =>
            @next elem, elem + 'c'
          , 100
        )
        Junc.func((elem, i, arr)->
          test.strictEqual elem, array[counter]
          test.strictEqual i, counter++
          test.deepEqual arr, array
          setTimeout =>
            @next elem, elem + 'd'
          , 200
        )
      ).complete((results0, results1)->
        test.deepEqual results0, [['a', 'ac'], ['a', 'ad']]
        test.deepEqual results1, [['b', 'bc'], ['b', 'bd']]
        test.done()
      ).start array

'test skip':
  serial: (test)->
    Junc.serial(
      Junc.func(->
          @global.str = 'a'
          @next()
      )
      Junc.serial(
        Junc.func(->
            @global.str += 'b'
            @next()
        )
        Junc.func(->
            if true
              @skip()
            else
              @global.str += 'c'
              @next()
        )
        Junc.func(->
            test.ok false, 'expect to be skipped'
            @global.str += 'd'
            @next()
        )
      )
      Junc.func(->
          @global.str += 'e'
          @next()
      )
    ).complete(
      ->
        test.strictEqual @global.str, 'abe'
        test.done()
    ).start()
  parallel: (test)->
    Junc.serial(
      Junc.func(->
          @global.value = 0
          @next()
      )
      Junc.parallel(
        Junc.func(->
            @global.value += 1
            @next()
        )
        Junc.func(->
            if true
              @skip()
            else
              @global.value += 2
              @next()
        )
        Junc.func(->
            test.ok false, 'expect to be skipped'
            @global.value += 3
            @next()
        )
      )
      Junc.func(->
          @global.value *= 10
          @next()
      )
    ).complete(
      ->
        test.strictEqual @global.value, 10
        test.done()
    ).start()

