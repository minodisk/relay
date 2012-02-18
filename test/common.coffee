fs = require 'fs'
Junc = require '../lib/browser/junc'

module.exports =

'test phase system':
  sync: (test)->
    junc = Junc.sync(->
        test.strictEqual @currentPhase, undefined
        test.strictEqual @totalPhase, undefined
    )
    junc.onComplete = ->
      test.strictEqual junc.currentPhase, undefined
      test.strictEqual junc.totalPhase, undefined
      test.done()
    junc.start()
  async: (test)->
    junc = Junc.async(->
        test.strictEqual @currentPhase, undefined
        test.strictEqual @totalPhase, undefined
        setTimeout @next, 10
    )
    junc.onComplete = ->
      test.strictEqual junc.currentPhase, undefined
      test.strictEqual junc.totalPhase, undefined
      test.done()
    junc.start()
  wait: (test)->
    junc = Junc.wait 10
    junc.onComplete = ->
    #TODO called twice
      test.strictEqual junc.currentPhase, undefined
      test.strictEqual junc.totalPhase, undefined
      test.done()
    junc.start()
  tween: (test)->
    target = {}
    junc = Junc.tween target, { a: 0 }, { a: 10 }, 10
    junc.onComplete = ->
      test.strictEqual junc.currentPhase, undefined
      test.strictEqual junc.totalPhase, undefined
      test.done()
    junc.start()
  to: (test)->
    target = { a: 0 }
    junc = Junc.to target, { a: 10 }, 10
    junc.onComplete = ->
      test.strictEqual junc.currentPhase, undefined
      test.strictEqual junc.totalPhase, undefined
      test.done()
    junc.start()

  serial:
    sync: (test)->
      junc = Junc.serial(
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 3
        )
        Junc.sync(->
            test.strictEqual @currentPhase, 1
            test.strictEqual @totalPhase, 3
        )
        Junc.sync(->
            test.strictEqual @currentPhase, 2
            test.strictEqual @totalPhase, 3
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    async: (test)->
      junc = Junc.serial(
        Junc.async(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 3
            setTimeout @next, 10
        )
        Junc.async(->
            test.strictEqual @currentPhase, 1
            test.strictEqual @totalPhase, 3
            setTimeout @next, 10
        )
        Junc.async(->
            test.strictEqual @currentPhase, 2
            test.strictEqual @totalPhase, 3
            setTimeout @next, 10
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    wait: (test)->
      junc = Junc.serial(
        Junc.wait(10)
        Junc.wait(10)
        Junc.wait(10)
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    mixed: (test)->
      target = {}
      junc = Junc.serial(
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 8
        )
        Junc.wait(10)
        Junc.async(->
            test.strictEqual @currentPhase, 2
            test.strictEqual @totalPhase, 8
            setTimeout @next, 10
        )
        Junc.sync(->
            test.strictEqual @currentPhase, 3
            test.strictEqual @totalPhase, 8
        )
        Junc.tween(target, {a: 0}, {a: 10}, 10)
        Junc.sync(->
            test.strictEqual @currentPhase, 5
            test.strictEqual @totalPhase, 8
        )
        Junc.to(target, {a: 20}, 10)
        Junc.sync(->
            test.strictEqual @currentPhase, 7
            test.strictEqual @totalPhase, 8
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 8
        test.strictEqual junc.totalPhase, 8
        test.done()
      junc.start()

  parallel:
    sync: (test)->
      junc = Junc.parallel(
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 3
        )
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 3
        )
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 3
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    async: (test)->
      junc = Junc.parallel(
        Junc.async(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 3
            setTimeout @next, 10
        )
        Junc.async(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 3
            setTimeout @next, 10
        )
        Junc.async(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 3
            setTimeout @next, 10
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    wait: (test)->
      junc = Junc.parallel(
        Junc.wait(10)
        Junc.wait(10)
        Junc.wait(10)
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    mixed: (test)->
      target = {}
      junc = Junc.parallel(
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 8
        )
        Junc.wait(10)
        Junc.async(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 8
            setTimeout @next, 10
        )
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 8
        )
        Junc.tween(target, {a: 0}, {a: 10}, 10)
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 8
        )
        Junc.to(target, {a: 20}, 10)
        Junc.sync(->
            test.strictEqual @currentPhase, 0
            test.strictEqual @totalPhase, 8
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 8
        test.strictEqual junc.totalPhase, 8
        test.done()
      junc.start()

  repeat:
    sync: (test)->
      counter = 0
      junc = Junc.repeat(
        Junc.sync(->
            test.strictEqual @currentPhase, counter++
            test.strictEqual @totalPhase, 3
        ), 3
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    async: (test)->
      counter = 0
      junc = Junc.repeat(
        Junc.async(->
            test.strictEqual @currentPhase, counter++
            test.strictEqual @totalPhase, 3
            setTimeout @next, 10
        ), 3
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    wait: (test)->
      junc = Junc.repeat(
        Junc.wait(10), 3
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    tween: (test)->
      target = {}
      junc = Junc.repeat(
        Junc.tween(target, { a: 0 }, { a: 10 }, 10), 3
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 3
        test.strictEqual junc.totalPhase, 3
        test.done()
      junc.start()
    serial: (test)->
      junc = Junc.repeat(
        Junc.serial(
          Junc.sync(->
              test.strictEqual @currentPhase, 0
              test.strictEqual @totalPhase, 3
          )
          Junc.sync(->
              test.strictEqual @currentPhase, 1
              test.strictEqual @totalPhase, 3
          )
          Junc.sync(->
              test.strictEqual @currentPhase, 2
              test.strictEqual @totalPhase, 3
          )
        ), 5
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 5
        test.strictEqual junc.totalPhase, 5
        test.done()
      junc.start()
    parallel: (test)->
      junc = Junc.repeat(
        Junc.parallel(
          Junc.sync(->
              test.strictEqual @currentPhase, 0
              test.strictEqual @totalPhase, 3
          )
          Junc.sync(->
              test.strictEqual @currentPhase, 0
              test.strictEqual @totalPhase, 3
          )
          Junc.sync(->
              test.strictEqual @currentPhase, 0
              test.strictEqual @totalPhase, 3
          )
        ), 5
      )
      junc.onComplete = ->
        test.strictEqual junc.currentPhase, 5
        test.strictEqual junc.totalPhase, 5
        test.done()
      junc.start()

'test nesting':
  serial:
    serial: (test)->
      counter = 0
      junc = Junc.serial(
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
      )
      junc.onComplete = ->
        test.strictEqual counter, 6
        test.done()
      junc.start()
    parallel: (test)->
      counter = 0
      junc = Junc.serial(
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
      )
      junc.onComplete = ->
        test.strictEqual counter, 6
        test.done()
      junc.start()
    repeat: (test)->
      counter = 0
      junc = Junc.serial(
        Junc.repeat(
          Junc.sync(->
              test.strictEqual counter++, @currentPhase
          ), 3
        )
        Junc.sync(->
            test.strictEqual counter++, 3
        )
        Junc.repeat(
          Junc.sync(->
              test.strictEqual counter++, 4 + @currentPhase
          ), 3
        )
      )
      junc.onComplete = ->
        test.strictEqual counter, 7
        test.done()
      junc.start()
    deep: (test)->
      counter = 0
      junc = Junc.serial(
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
      )
      junc.onComplete = ->
        test.strictEqual counter, 20
        test.done()
      junc.start()

'test shared params':
  sync: (test)->
    junc = Junc.sync(->
        @params.a = 'foo'
    )
    junc.onComplete = ->
      test.strictEqual junc.params.a, 'foo'
      test.done()
    junc.start()
  async: (test)->
    junc = Junc.async(->
        @params.a = 'foo'
        setTimeout @next, 10
    )
    junc.onComplete = ->
      test.strictEqual junc.params.a, 'foo'
      test.done()
    junc.start()

  serial:
    sync: (test)->
      junc = Junc.serial(
        Junc.sync(-> @params.str = 'foo')
        Junc.sync(-> @params.str += 'bar')
        Junc.sync(-> @params.str += 'baz')
      )
      junc.onComplete = ->
        test.strictEqual junc.params.str, 'foobarbaz'
        test.done()
      junc.start()
    serial: (test)->
      junc = Junc.serial(
        Junc.sync(-> @params.str = 'foo')
        Junc.serial(
          Junc.sync(-> @params.str += 'bar')
          Junc.sync(-> @params.str += 'baz')
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.params.str, 'foobarbaz'
        test.done()
      junc.start()
    parallel: (test)->
      junc = Junc.serial(
        Junc.sync(-> @params.num = 1)
        Junc.parallel(
          Junc.sync(-> @params.num += 2)
          Junc.sync(-> @params.num += 3)
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.params.num, 6
        test.done()
      junc.start()
    deep: (test)->
      junc = Junc.serial(
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
      )
      junc.onComplete = ->
        test.strictEqual junc.params.a, 129
        test.strictEqual junc.params.b, 'fooa---da---da---dg'
        test.deepEqual junc.params.c, { num: 10, str: 'barb===eb===eb===eh'}
        test.deepEqual junc.params.d, [514, 'bazc___fc___fc___fi']
        test.done()
      junc.start()

  parallel:
    sync: (test)->
      junc = Junc.parallel(
        Junc.sync(-> @params.num = 1)
        Junc.sync(-> @params.num += 2)
        Junc.sync(-> @params.num += 3)
      )
      junc.onComplete = ->
        test.strictEqual junc.params.num, 6
        test.done()
      junc.start()
    serial: (test)->
      junc = Junc.parallel(
        Junc.sync(-> @params.num = 1)
        Junc.serial(
          Junc.sync(-> @params.num += 2)
          Junc.sync(-> @params.num += 3)
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.params.num, 6
        test.done()
      junc.start()
    parallel: (test)->
      junc = Junc.parallel(
        Junc.sync(-> @params.num = 1)
        Junc.parallel(
          Junc.sync(-> @params.num += 2)
          Junc.sync(-> @params.num += 3)
        )
      )
      junc.onComplete = ->
        test.strictEqual junc.params.num, 6
        test.done()
      junc.start()

'test arguments':
  sync: (test)->
    junc = Junc.sync((a, b)->
        test.strictEqual a, 'a'
        test.strictEqual b, 'b'
    )
    junc.onComplete = ->
      test.done()
    junc.start 'a', 'b'
  async: (test)->
    junc = Junc.async((a, b)->
        test.strictEqual a, 'a'
        test.strictEqual b, 'b'
        @next a, b
    )
    junc.onComplete = (a, b)->
      test.strictEqual a, 'a'
      test.strictEqual b, 'b'
      test.done()
    junc.start 'a', 'b'
  file: (test)->
    junc = Junc.async(->
        fs.readFile "#{__dirname}/data/numbers.json", 'utf8', @next
    )
    junc.onComplete = (err, data)->
      numbers = JSON.parse data
      test.deepEqual numbers, [0, 1, 2, 3, 4]
      test.done()
    junc.start()

  serial:
    sync: (test)->
      junc = Junc.serial(
        Junc.sync((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
        )
      )
      junc.onComplete = ->
        test.done()
      junc.start 'a', 'b'
    async: (test)->
      junc = Junc.serial(
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
      )
      junc.onComplete = (e, f)->
        test.strictEqual e, 'e'
        test.strictEqual f, 'f'
        test.done()
      junc.start 'a', 'b'
    file: (test)->
      junc = Junc.serial(
        Junc.async(->
            fs.readFile "#{__dirname}/data/numbers.json", 'utf8', @next
        ),
        Junc.sync((err, data)->
            numbers = JSON.parse data
            test.deepEqual numbers, [0, 1, 2, 3, 4]
        )
      )
      junc.onComplete = ()->
        test.done()
      junc.start()

  parallel:
    sync: (test)->
      junc = Junc.parallel(
        Junc.sync((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
        )
        Junc.sync((a, b)->
            test.strictEqual a, 'a'
            test.strictEqual b, 'b'
        )
      )
      junc.onComplete = ->
        test.done()
      junc.start 'a', 'b'
    async: (test)->
      junc = Junc.parallel(
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
      )
      junc.onComplete = (args0, args1)->
        test.deepEqual args0, ['c', 'd']
        test.deepEqual args1, ['e', 'f']
        test.done()
      junc.start 'a', 'b'

'test dynamic construction':
  serial: (test)->
    Junc.serial(
      Junc.async(->
          @params.str = 'a'
          @next Junc.sync(->
              @params.str += 'b'
              console.log @params.str
          ), Junc.sync(->
              @params.str += 'c'
              console.log @params.str
          ), Junc.sync(->
              @params.str += 'd'
              console.log @params.str
          )
      )
      Junc.serial
      Junc.async(->
          console.log @
          console.log @params.str
          @next()
      )
    )
    .complete(
      (html)->
        test.done()
    ).start()
