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
      #TODO called twice
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
        @params.a = 'foo'
    ).complete(
      ->
        test.strictEqual @params.a, 'foo'
        test.done()
    ).start()
  async: (test)->
    Junc.async(
      ->
        @params.a = 'foo'
        setTimeout @next, 10
    ).complete(
      ->
        test.strictEqual @params.a, 'foo'
        test.done()
    ).start()

  serial:
    sync: (test)->
      Junc.serial(
        Junc.sync(-> @params.str = 'foo')
        Junc.sync(-> @params.str += 'bar')
        Junc.sync(-> @params.str += 'baz')
      ).complete(
        ->
          test.strictEqual @params.str, 'foobarbaz'
          test.done()
      ).start()
    serial: (test)->
      Junc.serial(
        Junc.sync(-> @params.str = 'foo')
        Junc.serial(
          Junc.sync(-> @params.str += 'bar')
          Junc.sync(-> @params.str += 'baz')
        )
      ).complete(
        ->
          test.strictEqual @params.str, 'foobarbaz'
          test.done()
      ).start()
    parallel: (test)->
      Junc.serial(
        Junc.sync(-> @params.num = 1)
        Junc.parallel(
          Junc.sync(-> @params.num += 2)
          Junc.sync(-> @params.num += 3)
        )
      ).complete(
        ->
          test.strictEqual @params.num, 6
          test.done()
      ).start()
    deep: (test)->
      Junc.serial(
        Junc.sync(->
            @params.a = 10
            @params.b = 'foo'
            @params.c = { num: 30, str: 'bar' }
            @params.d = [1, 'baz']
        )
        Junc.wait(10)
        Junc.repeat(
          Junc.parallel(
            Junc.sync(->
                @params.a += 1
                @params.b += 'a'
                @params.c.num -= 2
                @params.c.str += 'b'
                @params.d[0] *= 2
                @params.d[1] += 'c'
            )
            Junc.wait(10)
            Junc.serial(
              Junc.sync(->
                  @params.a *= 2
                  @params.c.num /= 2
                  @params.d[0] *= 2
              )
              Junc.wait(10)
              Junc.repeat(
                Junc.sync(->
                    @params.b += '-'
                    @params.c.str += '='
                    @params.d[1] += '_'
                ), 3
              )
            )
            Junc.wait(10)
            Junc.sync(->
                @params.a += 4
                @params.b += 'd'
                @params.c.num += 4
                @params.c.str += 'e'
                @params.d[0] *= 2
                @params.d[1] += 'f'
            )
          ), 3
        )
        Junc.wait(10)
        Junc.sync(->
            @params.a += 7
            @params.b += 'g'
            @params.c.num += 1
            @params.c.str += 'h'
            @params.d[0] += 2
            @params.d[1] += 'i'
        )
      ).complete(
        ->
          test.strictEqual @params.a, 129
          test.strictEqual @params.b, 'fooa---da---da---dg'
          test.deepEqual @params.c, { num: 10, str: 'barb===eb===eb===eh'}
          test.deepEqual @params.d, [514, 'bazc___fc___fc___fi']
          test.done()
      ).start()

  parallel:
    sync: (test)->
      Junc.parallel(
        Junc.sync(-> @params.num = 1)
        Junc.sync(-> @params.num += 2)
        Junc.sync(-> @params.num += 3)
      ).complete(
        ->
          test.strictEqual @params.num, 6
          test.done()
      ).start()
    serial: (test)->
      Junc.parallel(
        Junc.sync(-> @params.num = 1)
        Junc.serial(
          Junc.sync(-> @params.num += 2)
          Junc.sync(-> @params.num += 3)
        )
      ).complete(
        ->
          test.strictEqual @params.num, 6
          test.done()
      ).start()
    parallel: (test)->
      Junc.parallel(
        Junc.sync(-> @params.num = 1)
        Junc.parallel(
          Junc.sync(-> @params.num += 2)
          Junc.sync(-> @params.num += 3)
        )
      ).complete(
        ->
          test.strictEqual @params.num, 6
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
          @params.str = 'a'
          @next Junc.sync(->
              @params.str += 'b'
          ), Junc.sync(->
              @params.str += 'c'
          ), Junc.sync(->
              @params.str += 'd'
          )
      )
      Junc.serial
      Junc.sync(->
          @params.str += 'e'
      )
    ).complete(
      ->
        test.strictEqual @params.str, 'abcde'
        test.done()
    ).start()
  parallel: (test)->
    Junc.serial(
      Junc.sync(->
          @params.value = 0
          @next Junc.sync(->
              @params.value += 1
          ), Junc.sync(->
              @params.value += 2
          ), Junc.sync(->
              @params.value += 3
          )
      )
      Junc.parallel
      Junc.sync(->
          @params.value *= 10
      )
    ).complete(
      ->
        test.strictEqual @params.value, 60
        test.done()
    ).start()
