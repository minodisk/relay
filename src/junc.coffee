_slice = Array.prototype.slice
#if BROWSER
_PI = Math.PI
_PI_D = _PI * 2
_PI_H = _PI / 2
_abs = Math.abs
_pow = Math.pow
_sqrt = Math.sqrt
_sin = Math.sin
_cos = Math.cos
_asin = Math.asin
_requestAnimationFrame = do ->
  window?.requestAnimationFrame or
  window?.webkitRequestAnimationFrame or
  window?.mozRequestAnimationFrame or
  window?.msRequestAnimationFrame or
  window?.oRequestAnimationFrame or
  (callback) -> setTimeout (()->callback((new Date()).getTime())), 16.666666666666668
_isArray = Array.isArray || (obj)-> Object.prototype.toString.call(obj) is '[object Array]'
#else
_isArray = Array.isArray
#endif

class Junc

  @sync: (func)->
    new FunctionActor func, false

  @async: (func)->
    new FunctionActor func, true

  @wait: (delay)->
    new WaitActor delay

  @serial: (actors...)->
    if _isArray(actors[0])
      actors = actors[0]
    new SerialActor actors

  @parallel: (actors...)->
    if _isArray(actors[0])
      actors = actors[0]
    new ParallelActor actors

  @repeat: (actor, repeatCount)->
    new RepeatActor actor, repeatCount

  #if BROWSER
  @tween: (target, src, dst, duration = 1000, easing = Easing.linear)->
    new EasingActor target, src, dst, duration, easing

  @to: (target, dst, duration = 1000, easing = Easing.linear)->
    new EasingActor target, null, dst, duration, easing
#endif

class Actor

  constructor: ->
    @params = {}

  start: ->
    if @_running
      @stop()
    @_reset()
    @_running = true
    @

  stop: ->
    @_running = false
    @

  complete: (callback)->
    @onComplete = callback
    @

  _reset: ->

  _onStart: ->
    @onStart? @

  _onComplete: (args)->
    if @_running
      @_running = false
      @onComplete?.apply @, args

class FunctionActor extends Actor

  constructor: (@func, @async)->
    super()
    if typeof @func isnt 'function'
      throw new TypeError 'Arguments[0] of FunctionActor must be inspected Function.'

  start: (args...)->
    super()
    @func.apply @, args
    unless @async then @next()
    @

  next: (args...)=>
    @_onComplete args
    @

class WaitActor extends FunctionActor

  constructor: (delay)->
    super (->
      setTimeout @next, delay
    ), null, true

class GroupActor extends Actor

  constructor: (actors)->
    super()
    for actor in actors
      unless actor instanceof Actor or actor is Junc.serial or actor is Junc.parallel
        throw new TypeError 'Arguments[0] of GroupActor must be inspected Array of Actor.'
    @_src = actors
    @_dst = []
    @currentPhase = 0
    @totalPhase = actors.length

  stop: ->
    super()
    for actor in @_dst
      if actor instanceof Actor then actor.stop()
    @

  _reset: ->
    super()
    @currentPhase = 0
    for actor in @_dst
      actor._reset?()
    return

class SerialActor extends GroupActor

  constructor: (actors)->
    super actors

  start: (args...)->
    console.log 'start========'
    super()
    if @currentPhase < @totalPhase
      @_act @_getCurrentActor(args), args
      @_onStart()
    @

  next: (args...)=>
    console.log 'next---------'
    #TODO remove '?'
    @params = @_dst[@currentPhase]?.params
    if ++@currentPhase < @totalPhase
      actor = @_getCurrentActor args
      @_act actor, args
      console.log '+', actor?
    else if @currentPhase is @totalPhase
      @_onComplete args
    else
      @currentPhase = @totalPhase
    @

  _getCurrentActor: (args)->
    actor = @_src[@currentPhase]
    if actor is Junc.serial or actor is Junc.parallel
      actor = actor.apply Junc, args
      while args.length
        args.pop()
    @_dst[@currentPhase] = actor
    actor

  _act: (actor, args)->
    actor.onComplete = @next
    actor.params = @params
    if actor instanceof GroupActor
      actor.start args
    else
      actor.currentPhase = @currentPhase
      actor.totalPhase = @totalPhase
      actor.start.apply actor, args

class ParallelActor extends GroupActor

  constructor: (actors)->
    super actors
    @argsStorage = []

  start: (args...)->
    super()
    if @currentPhase < @totalPhase
      @_act args
      @_onStart()
    @

  next: (i, args...)=>
    @argsStorage[i] = args
    setTimeout (=>
      if ++@currentPhase >= @totalPhase
        @currentPhase = @totalPhase
        @_onComplete @argsStorage
    ), 0
    @

  _act: (args)->
    for actor, i in @_src
      actor.onComplete = do (i)=>
        (args...)=>
          args.unshift i
          @next.apply @, args
      actor.params = @params
      if actor instanceof GroupActor
        actor.start args
      else
        actor.currentPhase = @currentPhase
        actor.totalPhase = @totalPhase
        actor.start.apply actor, args

class RepeatActor extends SerialActor

  constructor: (actor, repeatCount)->
    actors = []
    while repeatCount--
      actors.push actor
    super actors

#if BROWSER
class EasingActor extends Actor

  constructor: (target, @src, @dst, @duration, @easing)->
    super()
    if window? and target instanceof window.HTMLElement
      @target = target.style
      @object = @_getStyle target
    else
      @target = @object = target
    @_requestAnimationFrame = AnimationFrameTicker.getInstance()

  start: ->
    super()
    object = @object
    src = @src
    dst = @dst
    changers = {}
    checkList = ['src', 'dst']
    for prop, value of src
      unless changers[prop]? then changers[prop] = {}
      changers[prop].src = value
    for prop, value of dst
      unless changers[prop]? then changers[prop] = {}
      changers[prop].dst = value
    for prop, changer of changers
      for srcOrDst in checkList
        value = changer[srcOrDst]
        unless value?
          value = object[prop]
        type = typeof value
        if type is 'number'
          changer[srcOrDst] = value
        else if type is 'string'
          value = value.match /(\d+)(\D*)/
          changer[srcOrDst] = Number value[1]
          unless changer.unit?
            changer.unit = if value[2]? then value[2] else ''
    @changers = changers
    @_beginningTime = new Date().getTime()
    @_requestAnimationFrame.addHandler @_update
    @onStart?()
    @

  _update: (time)=>
    @time = time - @_beginningTime
    if @time >= @duration
      @time = @duration
      factor = 1
      @_requestAnimationFrame.removeHandler @_update
    else
      factor = @easing(@time, 0, 1, @duration)
    target = @target
    changers = @changers
    for prop of changers
      changer = changers[prop]
      current = changer.src + (changer.dst - changer.src) * factor
      target[prop] = if changer.unit then "#{current}#{changer.unit}" else current
    @onUpdate?()
    if @time is @duration
      @_onComplete()
    return

  _getStyle: (element)->
    getComputedStyle(element, '') or element.currentStyle

class AnimationFrameTicker

  @getInstance: ->
    unless @instance?
      @internal = true
      @instance = new AnimationFrameTicker
    @instance

  constructor: ->
    unless AnimationFrameTicker.internal
      throw new Error "Ticker is singleton model, call Ticker.getInstance()."
    AnimationFrameTicker.internal = false
    @_handlers = []
    @_continuous = false
    @_counter = 0

  addHandler: (handler)=>
    @_handlers.push handler
    if @_continuous is false
      @_continuous = true
      _requestAnimationFrame @_onAnimationFrame
    return

  removeHandler: (handler)->
    @_handlers.splice @_handlers.indexOf(handler), 1
    if @_handlers.length is 0
      @_continuous = false
    return

  _onAnimationFrame: (time)=>
    @_counter++
    for handler in @_handlers
      do (handler) ->
        setTimeout (-> handler time), 0
    if @_continuous is true
      _requestAnimationFrame @_onAnimationFrame
    return

class Easing

  @linear: (t, b, c, d)->
    c * t / d + b

  @easeInQuad: (t, b, c, d)->
    t /= d
    c * t * t + b

  @easeOutQuad: (t, b, c, d)->
    t /= d
    -c * t * (t - 2) + b

  @easeInOutQuad: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      c / 2 * t * t + b
    else
      t--
      -c / 2 * (t * (t - 2) - 1) + b

  @easeOutInQuad: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      -c / 2 * t * (t - 2) + b
    else
      t--
      c / 2 * (t * t + 1) + b

  @easeInCubic: (t, b, c, d)->
    t /= d
    c * t * t * t + b

  @easeOutCubic: (t, b, c, d)->
    t = t / d - 1
    c * (t * t * t + 1) + b

  @easeInOutCubic: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      c / 2 * t * t * t + b
    else
      t -= 2
      c / 2 * (t * t * t + 2) + b

  @easeOutInCubic: (t, b, c, d)->
    t = t * 2 / d - 1
    c / 2 * (t * t * t + 1) + b

  @easeInQuart: (t, b, c, d)->
    t /= d
    c * t * t * t * t + b

  @easeOutQuart: (t, b, c, d)->
    t = t / d - 1
    -c * (t * t * t * t - 1) + b

  @easeInOutQuart: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      c / 2 * t * t * t * t + b
    else
      t -= 2
      -c / 2 * (t * t * t * t - 2) + b

  @easeOutInQuart: (t, b, c, d)->
    t = t * 2 / d - 1
    if t < 0
      -c / 2 * (t * t * t * t - 1) + b
    else
      c / 2 * (t * t * t * t + 1) + b

  @easeInQuint: (t, b, c, d)->
    t /= d
    c * t * t * t * t * t + b

  @easeOutQuint: (t, b, c, d)->
    t = t / d - 1
    c * (t * t * t * t * t + 1) + b

  @easeInOutQuint: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      c / 2 * t * t * t * t * t + b
    else
      t -= 2
      c / 2 * (t * t * t * t * t + 2) + b

  @easeOutInQuint: (t, b, c, d)->
    t = t * 2 / d - 1
    c / 2 * (t * t * t * t * t + 1) + b

  @easeInExpo: (t, b, c, d)->
    c * _pow(2, 10 * (t / d - 1)) + b

  @easeOutExpo: (t, b, c, d)->
    c * (1 - _pow(2, -10 * t / d)) + b

  @easeInOutExpo: (t, b, c, d)->
    t = t * 2 / d - 1
    if t < 0
      c / 2 * _pow(2, 10 * t) + b
    else
      c / 2 * (2 - _pow(2, -10 * t)) + b

  @easeOutInExpo: (t, b, c, d)->
    t *= 2 / d
    if t is 1
      c / 2 + b
    else if t < 1
      c / 2 * (1 - _pow(2, -10 * t)) + b
    else
      c / 2 * (1 + _pow(2, 10 * (t - 2))) + b

  @easeInSine: (t, b, c, d)->
    -c * (_cos(t / d * _PI_H) - 1) + b

  @easeOutSine: (t, b, c, d)->
    c * _sin(t / d * _PI_H) + b

  @easeInOutSine: (t, b, c, d)->
    -c / 2 * (_cos(_PI * t / d) - 1) + b

  @easeOutInSine: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      c / 2 * _sin(t * _PI_H) + b
    else
      -c / 2 * (_cos((t - 1) * _PI_H) - 2) + b

  @easeInCirc: (t, b, c, d)->
    t /= d
    -c * (_sqrt(1 - t * t) - 1) + b

  @easeOutCirc: (t, b, c, d)->
    t = t / d - 1
    c * _sqrt(1 - t * t) + b

  @easeInOutCirc: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      -c / 2 * (_sqrt(1 - t * t) - 1) + b
    else
      t -= 2
      c / 2 * (_sqrt(1 - t * t) + 1) + b

  @easeOutInCirc: (t, b, c, d)->
    t = t * 2 / d - 1
    if t < 0
      c / 2 * _sqrt(1 - t * t) + b
    else
      -c / 2 * (_sqrt(1 - t * t) - 2) + b

  @easeInBackWith: (s = 1.70158)->
    (t, b, c, d)->
      _s = s
      t /= d
      c * t * t * ((_s + 1) * t - _s) + b
  @easeInBack: Easing.easeInBackWith()

  @easeOutBackWith: (s = 1.70158)->
    (t, b, c, d)->
      _s = s
      t = t / d - 1
      c * (t * t * ((_s + 1) * t + _s) + 1) + b
  @easeOutBack: @easeOutBackWith()

  @easeInOutBackWith: (s = 1.70158)->
    (t, b, c, d)->
      _s = s * 1.525
      t *= 2 / d
      if t < 1
        c / 2 * (t * t * ((_s + 1) * t - _s)) + b
      else
        t -= 2
        c / 2 * (t * t * ((_s + 1) * t + _s) + 2) + b
  @easeInOutBack: @easeInOutBackWith()

  @easeOutInBackWith: (s = 1.70158)->
    (t, b, c, d)->
      _s = s
      t = t * 2 / d - 1
      if t < 0
        c / 2 * (t * t * ((_s + 1) * t + _s) + 1) + b
      else
        c / 2 * (t * t * ((_s + 1) * t - _s) + 1) + b
  @easeOutInBack: @easeOutInBackWith()

  @easeInBounce: (t, b, c, d)->
    t = 1 - t / d
    if t < 0.36363636363636365   # 4 / 11
      -c * (7.5625 * t * t - 1) + b
    else if t < 0.7272727272727273   # 8 / 11
      t -= 0.5454545454545454
      # 6 / 11
      -c * (7.5625 * t * t - 0.25) + b
    else if t < 0.9090909090909091   # 10 / 11
      t -= 0.8181818181818182
      # 9 / 11
      -c * (7.5625 * t * t - 0.0625) + b
    else
      t -= 0.9545454545454546
      # 10.5 / 11
      -c * (7.5625 * t * t - 0.015625) + b

  @easeOutBounce: (t, b, c, d)->
    t /= d
    if t < 0.36363636363636365   # 4 / 11
      c * (7.5625 * t * t) + b
    else if t < 0.7272727272727273   # 8 / 11
      t -= 0.5454545454545454
      # 6 / 11
      c * (7.5625 * t * t + 0.75) + b
    else if t < 0.9090909090909091   # 10 / 11
      t -= 0.8181818181818182
      # 9 / 11
      c * (7.5625 * t * t + 0.9375) + b
    else
      t -= 0.9545454545454546
      # 10.5 / 11
      c * (7.5625 * t * t + 0.984375) + b

  @easeInOutBounce: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      t = 1 - t
      if t < 0.36363636363636365   # 4 / 11
        -c / 2 * (7.5625 * t * t - 1) + b
      else if t < 0.7272727272727273   # 8 / 11
        t -= 0.5454545454545454
        # 6 / 11
        -c / 2 * (7.5625 * t * t - 0.25) + b
      else if t < 0.9090909090909091   # 10 / 11
        t -= 0.8181818181818182
        # 9 / 11
        -c / 2 * (7.5625 * t * t - 0.0625) + b
      else
        t -= 0.9545454545454546
        # 10.5 / 11
        -c / 2 * (7.5625 * t * t - 0.015625) + b
    else
      t -= 1
      if t < 0.36363636363636365   # 4 / 11
        c / 2 * (7.5625 * t * t + 1) + b
      else if t < 0.7272727272727273   # 8 / 11
        t -= 0.5454545454545454
        # 6 / 11
        c / 2 * (7.5625 * t * t + 1.75) + b
      else if t < 0.9090909090909091   # 10 / 11
        t -= 0.8181818181818182
        # 9 / 11
        c / 2 * (7.5625 * t * t + 1.9375) + b
      else
        t -= 0.9545454545454546
        # 10.5 / 11
        c / 2 * (7.5625 * t * t + 1.984375) + b

  @easeOutInBounce: (t, b, c, d)->
    t *= 2 / d
    if t < 1
      if t < 0.36363636363636365   # 4 / 11
        c / 2 * (7.5625 * t * t) + b
      else if t < 0.7272727272727273   # 8 / 11
        t -= 0.5454545454545454
        # 6 / 11
        c / 2 * (7.5625 * t * t + 0.75) + b
      else if t < 0.9090909090909091   # 10 / 11
        t -= 0.8181818181818182
        # 9 / 11
        c / 2 * (7.5625 * t * t + 0.9375) + b
      else
        t -= 0.9545454545454546
        # 10.5 / 11
        c / 2 * (7.5625 * t * t + 0.984375) + b
    else
      t = 2 - t
      if t < 0.36363636363636365   # 4 / 11
        -c / 2 * (7.5625 * t * t - 2) + b
      else if t < 0.7272727272727273   # 8 / 11
        t -= 0.5454545454545454
        # 6 / 11
        -c / 2 * (7.5625 * t * t - 1.25) + b
      else if t < 0.9090909090909091   # 10 / 11
        t -= 0.8181818181818182
        # 9 / 11
        -c / 2 * (7.5625 * t * t - 1.0625) + b
      else
        t -= 0.9545454545454546
        # 10.5 / 11
        -c / 2 * (7.5625 * t * t - 1.015625) + b

  @easeInElasticWith: (a = 0, p = 0)->
    (t, b, c, d)->
      _a = a
      _p = p
      t = t / d - 1
      if _p is 0
        _p = d * 0.3
      if _a is 0 or _a < _abs(c)
        _a = c
        s = _p / 4
      else
        s = _p / _PI_D * _asin(c / _a)
      -_a * _pow(2, 10 * t) * _sin((t * d - s) * _PI_D / _p) + b
  @easeInElastic: @easeInElasticWith()

  @easeOutElasticWith: (a = 0, p = 0)->
    (t, b, c, d)->
      _a = a
      _p = p
      t /= d
      if _p is 0
        _p = d * 0.3
      if _a is 0 or _a < _abs(c)
        _a = c
        s = _p / 4
      else
        s = _p / _PI_D * _asin(c / _a)
      _a * _pow(2, -10 * t) * _sin((t * d - s) * _PI_D / _p) + b + c
  @easeOutElastic: @easeOutElasticWith()

  @easeInOutElasticWith: (a = 0, p = 0)->
    (t, b, c, d)->
      _a = a
      _p = p
      t = t * 2 / d - 1
      if _p is 0
        _p = d * 0.45
      if _a is 0 or _a < _abs(c)
        _a = c
        s = _p / 4
      else
        s = _p / _PI_D * _asin(c / _a)
      if t < 0
        -_a / 2 * _pow(2, 10 * t) * _sin((t * d - s) * _PI_D / _p) + b
      else
        _a / 2 * _pow(2, -10 * t) * _sin((t * d - s) * _PI_D / _p) + b + c
  @easeInOutElastic: @easeInOutElasticWith()

  @easeOutInElasticWith: (a = 0, p = 0)->
    (t, b, c, d)->
      _a = a
      _p = p
      t = t * 2 / d
      c /= 2
      if _p is 0
        _p = d * 0.3
      if _a is 0 or _a < _abs(c)
        _a = c
        s = _p / 4
      else
        s = _p / _PI_D * _asin(c / _a)
      if t < 1
        _a * _pow(2, -10 * t) * _sin((t * d - s) * _PI_D / _p) + b + c
      else
        t -= 2
        -_a * _pow(2, 10 * t) * _sin((t * d - s) * _PI_D / _p) + b + c
  @easeOutInElastic: @easeOutInElasticWith()
#endif

#if BROWSER
if module?
  module.exports = Junc
else if define?
  define -> Junc
else if window?
  unless window.mn? then window.mn = {}
  unless window.mn.dsk? then window.mn.dsk = {}
  window.mn.dsk.Junc = Junc
#else
module.exports = Junc
#endif
