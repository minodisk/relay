fs = require 'fs'
Junc = require '../lib/browser/junc'

module.exports =

'test phase system':
  sync: (test)->
    Junc.sync(
      ->
        test.strictEqual @localIndex, undefined
        test.strictEqual @localLength, undefined
        test.strictEqual @globalIndex, undefined
    ).complete(
      ->
        test.strictEqual @localIndex, undefined
        test.strictEqual @localLength, undefined
        test.strictEqual @globalIndex, undefined
        test.done()
    ).start()
  async: (test)->
    Junc.async(
      ->
        test.strictEqual @localIndex, undefined
        test.strictEqual @localLength, undefined
        test.strictEqual @globalIndex, undefined
        setTimeout @next, 10
    ).complete(
      ->
        test.strictEqual @localIndex, undefined
        test.strictEqual @localLength, undefined
        test.strictEqual @globalIndex, undefined
        test.done()
    ).start()
  wait: (test)->
    Junc.wait(10).complete(
      ->
        test.strictEqual @localIndex, undefined
        test.strictEqual @localLength, undefined
        test.strictEqual @globalIndex, undefined
        test.done()
    ).start()
  tween: (test)->
    target = {}
    Junc.tween(target, { a: 0 }, { a: 10 }, 10).complete(
      ->
        test.strictEqual @localIndex, undefined
        test.strictEqual @localLength, undefined
        test.strictEqual @globalIndex, undefined
        test.done()
    ).start()
  to: (test)->
    target = { a: 0 }
    Junc.to(target, { a: 10 }, 10).complete(
      ->
        test.strictEqual @localIndex, undefined
        test.strictEqual @localLength, undefined
        test.strictEqual @globalIndex, undefined
        test.done()
    ).start()

  serial:
    sync: (test)->
      Junc.serial(
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 0
        )
        Junc.sync(->
            test.strictEqual @localIndex, 1
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 1
        )
        Junc.sync(->
            test.strictEqual @localIndex, 2
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 2
        )
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.done()
      ).start()
    async: (test)->
      Junc.serial(
        Junc.async(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 0
            setTimeout @next, 10
        )
        Junc.async(->
            test.strictEqual @localIndex, 1
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 1
            setTimeout @next, 10
        )
        Junc.async(->
            test.strictEqual @localIndex, 2
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 2
            setTimeout @next, 10
        )
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.done()
      ).start()
    wait: (test)->
      Junc.serial(
        Junc.wait(10)
        Junc.wait(10)
        Junc.wait(10)
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.done()
      ).start()
    mixed: (test)->
      target = {}
      Junc.serial(
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 0
        )
        Junc.wait(10)
        Junc.async(->
            test.strictEqual @localIndex, 2
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 2
            setTimeout @next, 10
        )
        Junc.sync(->
            test.strictEqual @localIndex, 3
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 3
        )
        Junc.tween(target, {a: 0}, {a: 10}, 10)
        Junc.sync(->
            test.strictEqual @localIndex, 5
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 5
        )
        Junc.to(target, {a: 20}, 10)
        Junc.sync(->
            test.strictEqual @localIndex, 7
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 7
        )
      ).complete(
        ->
          test.strictEqual @localIndex, 8
          test.strictEqual @localLength, 8
          test.strictEqual @globalIndex, 8
          test.done()
      ).start()

  parallel:
    sync: (test)->
      Junc.parallel(
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 0
        )
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 0
        )
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 0
        )
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.done()
      ).start()
    async: (test)->
      Junc.parallel(
        Junc.async(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 0
            setTimeout @next, 10
        )
        Junc.async(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 0
            setTimeout @next, 10
        )
        Junc.async(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, 0
            setTimeout @next, 10
        )
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.done()
      ).start()
    wait: (test)->
      Junc.parallel(
        Junc.wait(10)
        Junc.wait(10)
        Junc.wait(10)
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.done()
      ).start()
    mixed: (test)->
      target = {}
      Junc.parallel(
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 0
        )
        Junc.wait(10)
        Junc.async(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 0
            setTimeout @next, 10
        )
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 0
        )
        Junc.tween(target, {a: 0}, {a: 10}, 10)
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 0
        )
        Junc.to(target, {a: 20}, 10)
        Junc.sync(->
            test.strictEqual @localIndex, 0
            test.strictEqual @localLength, 8
            test.strictEqual @globalIndex, 0
        )
      ).complete(
        ->
          test.strictEqual @localIndex, 8
          test.strictEqual @localLength, 8
          test.strictEqual @globalIndex, 8
          test.done()
      ).start()

  repeat:
    sync: (test)->
      counter = 0
      Junc.repeat(
        Junc.sync(->
            test.strictEqual @localIndex, counter
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, counter
            test.strictEqual @repeatIndex, counter++, 'repeatIndex'
            test.strictEqual @repeatLength, 3
        ), 3
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.strictEqual @repeatIndex, 3
          test.strictEqual @repeatLength, 3
          test.done()
      ).start()
    async: (test)->
      counter = 0
      Junc.repeat(
        Junc.async(->
            test.strictEqual @localIndex, counter
            test.strictEqual @localLength, 3
            test.strictEqual @globalIndex, counter
            test.strictEqual @repeatIndex, counter++
            test.strictEqual @repeatLength, 3
            setTimeout @next, 10
        ), 3
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.strictEqual @repeatIndex, 3
          test.strictEqual @repeatLength, 3
          test.done()
      ).start()
    wait: (test)->
      Junc.repeat(
        Junc.wait(10), 3
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.strictEqual @repeatIndex, 3
          test.strictEqual @repeatLength, 3
          test.done()
      ).start()
    tween: (test)->
      target = {}
      Junc.repeat(
        Junc.tween(target, { a: 0 }, { a: 10 }, 10), 3
      ).complete(
        ->
          test.strictEqual @localIndex, 3
          test.strictEqual @localLength, 3
          test.strictEqual @globalIndex, 3
          test.strictEqual @repeatIndex, 3
          test.strictEqual @repeatLength, 3
          test.done()
      ).start()
    serial: (test)->
      Junc.repeat(
        Junc.serial(
          Junc.sync(->
              test.strictEqual @localIndex, 0
              test.strictEqual @localLength, 3
              test.strictEqual @globalIndex, 3 * @repeatIndex + 0
              test.strictEqual @repeatLength, 5
          )
          Junc.sync(->
              test.strictEqual @localIndex, 1
              test.strictEqual @localLength, 3
              test.strictEqual @globalIndex, 3 * @repeatIndex + 1
              test.strictEqual @repeatLength, 5
          )
          Junc.sync(->
              test.strictEqual @localIndex, 2
              test.strictEqual @localLength, 3
              test.strictEqual @globalIndex, 3 * @repeatIndex + 2
              test.strictEqual @repeatLength, 5
          )
        ), 5
      ).complete(
        ->
          test.strictEqual @localIndex, 5
          test.strictEqual @localLength, 5
          test.strictEqual @globalIndex, 15
          test.done()
      ).start()

    parallel: (test)->
      Junc.repeat(
        Junc.parallel(
          Junc.sync(->
              test.strictEqual @localIndex, 0
              test.strictEqual @localLength, 3
              test.strictEqual @globalIndex, 3 * @repeatIndex
          )
          Junc.sync(->
              test.strictEqual @localIndex, 0
              test.strictEqual @localLength, 3
              test.strictEqual @globalIndex, 3 * @repeatIndex
          )
          Junc.sync(->
              test.strictEqual @localIndex, 0
              test.strictEqual @localLength, 3
              test.strictEqual @globalIndex, 3 * @repeatIndex
          )
        ), 5
      ).complete(
        ->
          test.strictEqual @localIndex, 5
          test.strictEqual @localLength, 5
          test.strictEqual @globalIndex, 15
          test.done()
      ).start()

'test nesting':
  serial:
    serial: (test)->
      counter = 0
      Junc.serial(
        Junc.serial(
          Junc.sync(->
              test.strictEqual counter++, 0
          )
          Junc.sync(->
              test.strictEqual counter++, 1
          )
        )
        Junc.serial(
          Junc.sync(->
              test.strictEqual counter++, 2
          )
          Junc.sync(->
              test.strictEqual counter++, 3
          )
        )
        Junc.serial(
          Junc.sync(->
              test.strictEqual counter++, 4
          )
          Junc.sync(->
              test.strictEqual counter++, 5
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
          Junc.sync(->
              test.strictEqual counter++, 0
          )
          Junc.sync(->
              test.strictEqual counter++, 1
          )
        )
        Junc.parallel(
          Junc.sync(->
              test.strictEqual counter++, 2
          )
          Junc.sync(->
              test.strictEqual counter++, 3
          )
        )
        Junc.parallel(
          Junc.sync(->
              test.strictEqual counter++, 4
          )
          Junc.sync(->
              test.strictEqual counter++, 5
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
          Junc.sync(->
              test.strictEqual counter++, @localIndex
          ), 3
        )
        Junc.sync(->
            test.strictEqual counter++, 3
        )
        Junc.repeat(
          Junc.sync(->
              test.strictEqual counter++, 4 + @localIndex
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
        Junc.sync(-> counter++)
        Junc.wait(10)
        Junc.repeat(
          Junc.parallel(
            Junc.sync(-> counter++)
            Junc.wait(10)
            Junc.serial(
              Junc.sync(-> counter++)
              Junc.wait(10)
              Junc.repeat(Junc.sync(-> counter++), 3)
            )
            Junc.wait(10)
            Junc.sync(-> counter++)
          ), 3
        )
        Junc.wait(10)
        Junc.sync(-> counter++)
      ).complete(
        ->
          test.strictEqual counter, 20
          test.done()
      ).start()

'test shared params':
  sync: (test)->
    Junc.sync(
      ->
        @global.a = 'foo'
    ).complete(
      ->
        test.strictEqual @global.a, 'foo'
        test.done()
    ).start()
  async: (test)->
    Junc.async(
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
        Junc.sync(->
            @local.str = 'foo'
            @global.str = 'foo'
        )
        Junc.sync(->
            @local.str += 'bar'
            @global.str += 'bar'
        )
        Junc.sync(->
            @local.str += 'baz'
            @global.str += 'baz'
        )
      ).complete(
        ->
          test.strictEqual @local.str, 'foobarbaz'
          test.strictEqual @global.str, 'foobarbaz'
          test.done()
      ).start()
    serial: (test)->
      Junc.serial(
        Junc.sync(->
            @local.str = 'foo'
            @global.str = 'foo'
        )
        Junc.serial(
          Junc.sync(->
              test.strictEqual @local.str, undefined
              @local.str = 'bar'
              @global.str += 'bar'
          )
          Junc.sync(->
              @local.str += 'baz'
              @global.str += 'baz'
              test.strictEqual @local.str, 'barbaz'
          )
        )
        Junc.sync(->
            @local.str += 'qux'
            @global.str += 'qux'
        )
      ).complete(
        ->
          test.strictEqual @local.str, 'fooqux'
          test.strictEqual @global.str, 'foobarbazqux'
          test.done()
      ).start()
    parallel: (test)->
      Junc.serial(
        Junc.sync(->
            @local.num = 2
            @global.num = 2
        )
        Junc.parallel(
          Junc.sync(->
              test.strictEqual @local.num, undefined
              @local.num = 3
              @global.num *= 3
          )
          Junc.sync(->
              @local.num *= 4
              @global.num *= 4
              test.strictEqual @local.num, 12
          )
        )
        Junc.sync(->
            @local.num += 1
            @global.num += 1
        )
      ).complete(
        ->
          test.strictEqual @local.num, 3
          test.strictEqual @global.num, 25
          test.done()
      ).start()
    deep: (test)->
      Junc.serial(
        Junc.sync(->
            @local.a = 10
            @global.a = 10
            @global.b = 'foo'
            @global.c = { num: 30, str: 'bar' }
            @global.d = [1, 'baz']
        )
        Junc.wait(10)
        Junc.repeat(
          Junc.parallel(
            Junc.sync(->
                test.strictEqual @local.a, undefined
                @local.a = 1
                @global.a += 1
                @global.b += 'a'
                @global.c.num -= 2
                @global.c.str += 'b'
                @global.d[0] *= 2
                @global.d[1] += 'c'
                test.strictEqual @local.a, 1
            )
            Junc.wait(10)
            Junc.serial(
              Junc.sync(->
                  test.strictEqual @local.a, undefined
                  @local.a = 2
                  @global.a *= 2
                  @global.c.num /= 2
                  @global.d[0] *= 2
              )
              Junc.wait(10)
              Junc.repeat(
                Junc.sync(->
                    if @repeatIndex is 0
                      @local.a = 2
                    else
                      @local.a *= 2
                    if @repeatIndex is 2
                      test.strictEqual @local.a, 8
                    @global.b += '-'
                    @global.c.str += '='
                    @global.d[1] += '_'
                ), 3
              )
            )
            Junc.wait(10)
            Junc.sync(->
                @local.a += 4
                @global.a += 4
                @global.b += 'd'
                @global.c.num += 4
                @global.c.str += 'e'
                @global.d[0] *= 2
                @global.d[1] += 'f'
                test.strictEqual @local.a, 5
            )
          ), 3
        )
        Junc.wait(10)
        Junc.sync(->
            @local.a += 7
            @global.a += 7
            @global.b += 'g'
            @global.c.num += 1
            @global.c.str += 'h'
            @global.d[0] += 2
            @global.d[1] += 'i'
        )
      ).complete(
        ->
          test.strictEqual @local.a, 17
          test.strictEqual @global.a, 129
          test.strictEqual @global.b, 'fooa---da---da---dg'
          test.deepEqual @global.c, { num: 10, str: 'barb===eb===eb===eh'}
          test.deepEqual @global.d, [514, 'bazc___fc___fc___fi']
          test.done()
      ).start()

  parallel:
    sync: (test)->
      Junc.parallel(
        Junc.sync(-> @global.num = 1)
        Junc.sync(-> @global.num += 2)
        Junc.sync(-> @global.num += 3)
      ).complete(
        ->
          test.strictEqual @global.num, 6
          test.done()
      ).start()
    serial: (test)->
      Junc.parallel(
        Junc.sync(-> @global.num = 1)
        Junc.serial(
          Junc.sync(-> @global.num += 2)
          Junc.sync(-> @global.num += 3)
        )
      ).complete(
        ->
          test.strictEqual @global.num, 6
          test.done()
      ).start()
    parallel: (test)->
      Junc.parallel(
        Junc.sync(-> @global.num = 1)
        Junc.parallel(
          Junc.sync(-> @global.num += 2)
          Junc.sync(-> @global.num += 3)
        )
      ).complete(
        ->
          test.strictEqual @global.num, 6
          test.done()
      ).start()

'test arguments':
  sync: (test)->
    Junc.sync(
      (a, b)->
        test.strictEqual a, 'a'
        test.strictEqual b, 'b'
    ).complete(
      ->
        test.done()
    ).start 'a', 'b'
  async: (test)->
    Junc.async(
      (a, b)->
        test.strictEqual a, 'a'
        test.strictEqual b, 'b'
        @next a, b
    ).complete(
      (a, b)->
        test.strictEqual a, 'a'
        test.strictEqual b, 'b'
        test.done()
    ).start 'a', 'b'
  file: (test)->
    Junc.async(
      ->
        fs.readFile "#{__dirname}/data/numbers.json", 'utf8', @next
    ).complete(
      (err, data)->
        numbers = JSON.parse data
        test.deepEqual numbers, [0, 1, 2, 3, 4]
        test.done()
    ).start()

  serial:
    sync: (test)->
      Junc.serial(
        Junc.sync((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
        )
      ).complete(
        ->
          test.done()
      ).start 'a', 'b'
    async: (test)->
      Junc.serial(
        Junc.async((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'c', 'd'
        )
        Junc.async((c, d)->
            test.strictEqual c, 'c'
            test.strictEqual d, 'd'
            @next 'e', 'f'
        )
      ).complete(
        (e, f)->
          test.strictEqual e, 'e'
          test.strictEqual f, 'f'
          test.done()
      ).start 'a', 'b'
    file: (test)->
      Junc.serial(
        Junc.async(->
            fs.readFile "#{__dirname}/data/numbers.json", 'utf8', @next
        ),
        Junc.sync((err, data)->
            numbers = JSON.parse data
            test.deepEqual numbers, [0, 1, 2, 3, 4]
        )
      ).complete(
        ()->
          test.done()
      ).start()

  parallel:
    sync: (test)->
      Junc.parallel(
        Junc.sync((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
        )
        Junc.sync((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
        )
      ).complete(
        ->
          test.done()
      ).start 'a', 'b'
    async: (test)->
      Junc.parallel(
        Junc.async((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'c', 'd'
        )
        Junc.async((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
            @next 'e', 'f'
        )
      ).complete(
        (args0, args1)->
          test.deepEqual args0, ['c', 'd']
          test.deepEqual args1, ['e', 'f']
          test.done()
      ).start 'a', 'b'

'test dynamic construction':
  serial: (test)->
    Junc.serial(
      Junc.sync(->
          @global.str = 'a'
          @next Junc.sync(->
              @global.str += 'b'
          ), Junc.sync(->
              @global.str += 'c'
          ), Junc.sync(->
              @global.str += 'd'
          )
      )
      Junc.serial
      Junc.sync(->
          @global.str += 'e'
      )
    ).complete(
      ->
        test.strictEqual @global.str, 'abcde'
        test.done()
    ).start()
  parallel: (test)->
    Junc.serial(
      Junc.sync(->
          @global.value = 0
          @next Junc.sync(->
              @global.value += 1
          ), Junc.sync(->
              @global.value += 2
          ), Junc.sync(->
              @global.value += 3
          )
      )
      Junc.parallel
      Junc.sync(->
          @global.value *= 10
      )
    ).complete(
      ->
        test.strictEqual @global.value, 60
        test.done()
    ).start()
    