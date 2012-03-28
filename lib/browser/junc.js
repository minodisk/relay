(function() {
  var Actor, AnimationFrameTicker, Easing, EasingActor, FunctionActor, GroupActor, Junc, ParallelActor, ParallelEachActor, RepeatActor, SerialActor, WaitActor, _PI, _PI_D, _PI_H, _abs, _asin, _cos, _isArray, _pow, _requestAnimationFrame, _sin, _slice, _sqrt,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  _slice = Array.prototype.slice;

  _PI = Math.PI;

  _PI_D = _PI * 2;

  _PI_H = _PI / 2;

  _abs = Math.abs;

  _pow = Math.pow;

  _sqrt = Math.sqrt;

  _sin = Math.sin;

  _cos = Math.cos;

  _asin = Math.asin;

  _requestAnimationFrame = (function() {
    return (typeof window !== "undefined" && window !== null ? window.requestAnimationFrame : void 0) || (typeof window !== "undefined" && window !== null ? window.webkitRequestAnimationFrame : void 0) || (typeof window !== "undefined" && window !== null ? window.mozRequestAnimationFrame : void 0) || (typeof window !== "undefined" && window !== null ? window.msRequestAnimationFrame : void 0) || (typeof window !== "undefined" && window !== null ? window.oRequestAnimationFrame : void 0) || function(callback) {
      return setTimeout((function() {
        return callback(new Date().getTime());
      }), 16.666666666666668);
    };
  })();

  _isArray = Array.isArray || function(obj) {
    return Object.prototype.toString.call(obj) === '[object Array]';
  };

  Junc = (function() {

    function Junc() {}

    Junc.func = function(func) {
      var len;
      if ((len = arguments.length) !== 1) {
        throw new TypeError("Junc.func() takes exactly 1 argument (" + len + " given)");
      }
      return new FunctionActor(func);
    };

    Junc.wait = function(delay) {
      var len;
      if ((len = arguments.length) !== 1) {
        throw new TypeError("Junc.wait() takes exactly 1 argument (" + len + " given)");
      }
      return new WaitActor(delay);
    };

    Junc.serial = function(actors) {
      if (!_isArray(actors)) {
        actors = arguments.length > 0 ? _slice.call(arguments, 0) : [];
      }
      return new SerialActor(actors);
    };

    Junc.parallel = function(actors) {
      if (!_isArray(actors)) {
        actors = arguments.length > 0 ? _slice.call(arguments, 0) : [];
      }
      return new ParallelActor(actors);
    };

    Junc.each = function(actor, isSerial) {
      var len;
      if (isSerial == null) isSerial = false;
      if ((len = arguments.length) !== 1 && len !== 2) {
        throw new TypeError("Junc.each() takes exactly 2 arguments (" + len + " given)");
      }
      if (isSerial) {
        return new SerialEachActor(actor);
      } else {
        return new ParallelEachActor(actor);
      }
    };

    Junc.repeat = function(actor, repeatCount) {
      var len;
      if ((len = arguments.length) !== 2) {
        throw new TypeError("Junc.repeat() takes exactly 2 arguments (" + len + " given)");
      }
      return new RepeatActor(actor, repeatCount);
    };

    Junc.tween = function(target, src, dst, duration, easing) {
      if (duration == null) duration = 1000;
      if (easing == null) easing = Easing.linear;
      return new EasingActor(target, src, dst, duration, easing);
    };

    Junc.to = function(target, dst, duration, easing) {
      if (duration == null) duration = 1000;
      if (easing == null) easing = Easing.linear;
      return new EasingActor(target, null, dst, duration, easing);
    };

    return Junc;

  })();

  Actor = (function() {

    function Actor() {
      this.root = this;
    }

    Actor.prototype.start = function() {
      this._reset();
      return this;
    };

    Actor.prototype.stop = function() {
      return this;
    };

    Actor.prototype.complete = function(callback) {
      this.onComplete = callback;
      return this;
    };

    Actor.prototype._reset = function() {
      if (this === this.root) return this.global = {};
    };

    Actor.prototype._onStart = function() {
      return typeof this.onStart === "function" ? this.onStart(this) : void 0;
    };

    Actor.prototype._onComplete = function(args) {
      var _ref;
      return (_ref = this.onComplete) != null ? _ref.apply(this, args) : void 0;
    };

    return Actor;

  })();

  FunctionActor = (function(_super) {

    __extends(FunctionActor, _super);

    function FunctionActor(_func) {
      this._func = _func;
      this.next = __bind(this.next, this);
      FunctionActor.__super__.constructor.call(this);
      if (typeof this._func !== 'function') {
        throw new TypeError('new FunctionActor(func) func must be inspected Function.');
      }
    }

    FunctionActor.prototype.clone = function() {
      return new FunctionActor(this._func);
    };

    FunctionActor.prototype.start = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      FunctionActor.__super__.start.call(this);
      this._func.apply(this, args);
      return this;
    };

    FunctionActor.prototype.next = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this._onComplete(args);
      return this;
    };

    FunctionActor.prototype._onComplete = function(args) {
      FunctionActor.__super__._onComplete.call(this, args);
    };

    return FunctionActor;

  })(Actor);

  WaitActor = (function(_super) {

    __extends(WaitActor, _super);

    function WaitActor(_delay) {
      this._delay = _delay;
      if (isNaN(this._delay)) {
        throw new TypeError('new WaitActor(delay) delay must be inspected Number.');
      }
      WaitActor.__super__.constructor.call(this, (function() {
        return setTimeout(this.next, this._delay);
      }), null, true);
    }

    WaitActor.prototype.clone = function() {
      return new WaitActor(this._delay);
    };

    return WaitActor;

  })(FunctionActor);

  GroupActor = (function(_super) {

    __extends(GroupActor, _super);

    function GroupActor(actors) {
      var actor, i, _len;
      GroupActor.__super__.constructor.call(this);
      this._actors = [];
      this.__actors = [];
      for (i = 0, _len = actors.length; i < _len; i++) {
        actor = actors[i];
        if (!(actor instanceof Actor)) {
          throw new TypeError('Arguments[0] of GroupActor must be inspected Array of Actor.');
        }
        this._actors[i] = actor.clone();
        this.__actors[i] = actor.clone();
      }
    }

    GroupActor.prototype.stop = function() {
      var actor, _i, _len, _ref;
      GroupActor.__super__.stop.call(this);
      _ref = this._actors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        if (actor instanceof Actor) actor.stop();
      }
      return this;
    };

    GroupActor.prototype._reset = function() {
      var actor, _i, _len, _ref;
      GroupActor.__super__._reset.call(this);
      this.local = {
        index: 0,
        length: this._actors.length
      };
      if (this === this.root) this.global.index = 0;
      _ref = this._actors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        actor._reset();
      }
    };

    GroupActor.prototype._act = function(actor, args) {
      var _ref,
        _this = this;
      actor.root = this.root;
      actor.skip = function() {
        _this.local.index = _this.local.length;
        return _this._onComplete();
      };
      if (!(actor instanceof RepeatActor)) actor.repeatRoot = this.repeatRoot;
      actor.global = this.global;
      actor.repeat = (_ref = this.repeatRoot) != null ? _ref.repeat : void 0;
      if (!(actor instanceof GroupActor)) actor.local = this.local;
      actor.start.apply(actor, args);
    };

    return GroupActor;

  })(Actor);

  SerialActor = (function(_super) {

    __extends(SerialActor, _super);

    function SerialActor() {
      this.next = __bind(this.next, this);
      SerialActor.__super__.constructor.apply(this, arguments);
    }

    SerialActor.prototype.clone = function() {
      return new SerialActor(this.__actors);
    };

    SerialActor.prototype.start = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      SerialActor.__super__.start.call(this);
      if (this.local.index < this.local.length) {
        this._act(this._actors[this.local.index], args);
        this._onStart();
      }
      return this;
    };

    SerialActor.prototype.next = function() {
      var actor, args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      actor = this._actors[this.local.index];
      this.local.index++;
      if (actor instanceof GroupActor) {
        this.global.index = this.root.global.index;
      } else {
        this.root.global.index++;
      }
      if (this.local.index < this.local.length) {
        this._act(this._actors[this.local.index], args);
      } else if (this.local.index === this.local.length) {
        this._onComplete(args);
      }
      return this;
    };

    SerialActor.prototype._act = function(actor, args) {
      actor.onComplete = this.next;
      SerialActor.__super__._act.call(this, actor, args);
    };

    return SerialActor;

  })(GroupActor);

  ParallelActor = (function(_super) {

    __extends(ParallelActor, _super);

    function ParallelActor() {
      this.next = __bind(this.next, this);
      ParallelActor.__super__.constructor.apply(this, arguments);
    }

    ParallelActor.prototype.clone = function() {
      return new ParallelActor(this.__actors);
    };

    ParallelActor.prototype.start = function() {
      var actor, args, i, _len, _ref,
        _this = this;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ParallelActor.__super__.start.call(this);
      this._storage = [];
      if (this.local.index < this.local.length) {
        _ref = this._actors;
        for (i = 0, _len = _ref.length; i < _len; i++) {
          actor = _ref[i];
          actor.onComplete = (function(i) {
            return function() {
              var args;
              args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              args.unshift(i);
              return _this.next.apply(_this, args);
            };
          })(i);
          if (this.local.index < this.local.length) this._act(actor, args, i);
        }
        this._onStart();
      }
      return this;
    };

    ParallelActor.prototype.next = function() {
      var args, i,
        _this = this;
      i = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this._storage[i] = args;
      setTimeout((function() {
        _this.local.index++;
        _this.root.global.index++;
        if (_this.local.index >= _this.local.length) {
          _this.local.index = _this.local.length;
          return _this._onComplete(_this._storage);
        }
      }), 0);
      return this;
    };

    return ParallelActor;

  })(GroupActor);

  ParallelEachActor = (function(_super) {

    __extends(ParallelEachActor, _super);

    function ParallelEachActor(actor) {
      ParallelEachActor.__super__.constructor.call(this, [actor]);
    }

    ParallelEachActor.prototype.clone = function() {
      return new ParallelEachActor(this.__actors[0]);
    };

    ParallelEachActor.prototype.start = function(args) {
      var arg, i, _len;
      this._actors = [];
      for (i = 0, _len = args.length; i < _len; i++) {
        arg = args[i];
        this._actors[i] = this.__actors[0].clone();
      }
      return ParallelEachActor.__super__.start.apply(this, args);
    };

    ParallelEachActor.prototype._act = function(actor, args, i) {
      return ParallelEachActor.__super__._act.call(this, actor, [args[i]]);
    };

    return ParallelEachActor;

  })(ParallelActor);

  /*
  class SerialEachActor extends EachActor
  
    clone: ->
      new SerialEachActor @_actor
  
    start: (@_array)->
      super()
      @_storage = []
      @_act()
      @_onStart()
      @
  
    next: (args...)=>
      @_storage[@local.index] = args
      @local.index++
      if @_actor instanceof GroupActor
        @global.index = @root.global.index
      else
        @root.global.index++
      if @local.index < @local.length
        @_act()
      else if @local.index is @local.length
        @_onComplete @_storage
      @
  
    _act: ->
      @_actor.onComplete = @next
      super @_actor, [@_array[@local.index], @local.index, @_array]
      return
  */

  RepeatActor = (function(_super) {

    __extends(RepeatActor, _super);

    function RepeatActor(actor, repeatCount) {
      var actors;
      actors = [];
      while (repeatCount--) {
        actors.push(actor);
      }
      RepeatActor.__super__.constructor.call(this, actors);
      this.repeatRoot = this;
    }

    RepeatActor.prototype.next = function() {
      this.repeat.index++;
      return RepeatActor.__super__.next.call(this);
    };

    RepeatActor.prototype._reset = function() {
      RepeatActor.__super__._reset.call(this);
      return this.repeat = {
        index: 0,
        length: this._actors.length
      };
    };

    return RepeatActor;

  })(SerialActor);

  EasingActor = (function(_super) {

    __extends(EasingActor, _super);

    EasingActor._getStyle = function(element) {
      return getComputedStyle(element, '') || element.currentStyle;
    };

    function EasingActor(_target, src, dst, duration, easing) {
      this._target = _target;
      this.src = src;
      this.dst = dst;
      this.duration = duration;
      this.easing = easing;
      this._update = __bind(this._update, this);
      EasingActor.__super__.constructor.call(this);
      if ((typeof window !== "undefined" && window !== null) && this._target instanceof window.HTMLElement) {
        this.target = this._target.style;
        this.object = EasingActor._getStyle(this._target);
      } else {
        this.target = this.object = this._target;
      }
      this._requestAnimationFrame = AnimationFrameTicker.getInstance();
    }

    EasingActor.prototype.clone = function() {
      return new EasingActor(this._target, this.src, this.dst, this.duration, this.easing);
    };

    EasingActor.prototype.start = function() {
      var changer, changers, checkList, dst, object, prop, src, srcOrDst, type, value, _i, _len;
      EasingActor.__super__.start.call(this);
      object = this.object;
      src = this.src;
      dst = this.dst;
      changers = {};
      checkList = ['src', 'dst'];
      for (prop in src) {
        value = src[prop];
        if (changers[prop] == null) changers[prop] = {};
        changers[prop].src = value;
      }
      for (prop in dst) {
        value = dst[prop];
        if (changers[prop] == null) changers[prop] = {};
        changers[prop].dst = value;
      }
      for (prop in changers) {
        changer = changers[prop];
        for (_i = 0, _len = checkList.length; _i < _len; _i++) {
          srcOrDst = checkList[_i];
          value = changer[srcOrDst];
          if (value == null) value = object[prop];
          type = typeof value;
          if (type === 'number') {
            changer[srcOrDst] = value;
          } else if (type === 'string') {
            value = value.match(/(\d+)(\D*)/);
            changer[srcOrDst] = Number(value[1]);
            if (changer.unit == null) {
              changer.unit = value[2] != null ? value[2] : '';
            }
          }
        }
      }
      this.changers = changers;
      this._beginningTime = new Date().getTime();
      this._requestAnimationFrame.addHandler(this._update);
      if (typeof this.onStart === "function") this.onStart();
      return this;
    };

    EasingActor.prototype._update = function(time) {
      var changer, changers, current, factor, prop, target;
      this.time = time - this._beginningTime;
      if (this.time >= this.duration) {
        this.time = this.duration;
        factor = 1;
        this._requestAnimationFrame.removeHandler(this._update);
      } else {
        factor = this.easing(this.time, 0, 1, this.duration);
      }
      target = this.target;
      changers = this.changers;
      for (prop in changers) {
        changer = changers[prop];
        current = changer.src + (changer.dst - changer.src) * factor;
        target[prop] = changer.unit ? "" + current + changer.unit : current;
      }
      if (typeof this.onUpdate === "function") this.onUpdate();
      if (this.time === this.duration) this._onComplete();
    };

    return EasingActor;

  })(Actor);

  AnimationFrameTicker = (function() {

    AnimationFrameTicker.getInstance = function() {
      if (this.instance == null) {
        this.internal = true;
        this.instance = new AnimationFrameTicker;
      }
      return this.instance;
    };

    function AnimationFrameTicker() {
      this._onAnimationFrame = __bind(this._onAnimationFrame, this);
      this.addHandler = __bind(this.addHandler, this);      if (!AnimationFrameTicker.internal) {
        throw new Error("Ticker is singleton model, call Ticker.getInstance().");
      }
      AnimationFrameTicker.internal = false;
      this._handlers = [];
      this._continuous = false;
      this._counter = 0;
    }

    AnimationFrameTicker.prototype.addHandler = function(handler) {
      this._handlers.push(handler);
      if (this._continuous === false) {
        this._continuous = true;
        _requestAnimationFrame(this._onAnimationFrame);
      }
    };

    AnimationFrameTicker.prototype.removeHandler = function(handler) {
      this._handlers.splice(this._handlers.indexOf(handler), 1);
      if (this._handlers.length === 0) this._continuous = false;
    };

    AnimationFrameTicker.prototype._onAnimationFrame = function(time) {
      var handler, _fn, _i, _len, _ref;
      this._counter++;
      _ref = this._handlers;
      _fn = function(handler) {
        return setTimeout((function() {
          return handler(time);
        }), 0);
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        handler = _ref[_i];
        _fn(handler);
      }
      if (this._continuous === true) {
        _requestAnimationFrame(this._onAnimationFrame);
      }
    };

    return AnimationFrameTicker;

  })();

  Easing = (function() {

    function Easing() {}

    Easing.linear = function(t, b, c, d) {
      return c * t / d + b;
    };

    Easing.easeInQuad = function(t, b, c, d) {
      t /= d;
      return c * t * t + b;
    };

    Easing.easeOutQuad = function(t, b, c, d) {
      t /= d;
      return -c * t * (t - 2) + b;
    };

    Easing.easeInOutQuad = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        return c / 2 * t * t + b;
      } else {
        t--;
        return -c / 2 * (t * (t - 2) - 1) + b;
      }
    };

    Easing.easeOutInQuad = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        return -c / 2 * t * (t - 2) + b;
      } else {
        t--;
        return c / 2 * (t * t + 1) + b;
      }
    };

    Easing.easeInCubic = function(t, b, c, d) {
      t /= d;
      return c * t * t * t + b;
    };

    Easing.easeOutCubic = function(t, b, c, d) {
      t = t / d - 1;
      return c * (t * t * t + 1) + b;
    };

    Easing.easeInOutCubic = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        return c / 2 * t * t * t + b;
      } else {
        t -= 2;
        return c / 2 * (t * t * t + 2) + b;
      }
    };

    Easing.easeOutInCubic = function(t, b, c, d) {
      t = t * 2 / d - 1;
      return c / 2 * (t * t * t + 1) + b;
    };

    Easing.easeInQuart = function(t, b, c, d) {
      t /= d;
      return c * t * t * t * t + b;
    };

    Easing.easeOutQuart = function(t, b, c, d) {
      t = t / d - 1;
      return -c * (t * t * t * t - 1) + b;
    };

    Easing.easeInOutQuart = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        return c / 2 * t * t * t * t + b;
      } else {
        t -= 2;
        return -c / 2 * (t * t * t * t - 2) + b;
      }
    };

    Easing.easeOutInQuart = function(t, b, c, d) {
      t = t * 2 / d - 1;
      if (t < 0) {
        return -c / 2 * (t * t * t * t - 1) + b;
      } else {
        return c / 2 * (t * t * t * t + 1) + b;
      }
    };

    Easing.easeInQuint = function(t, b, c, d) {
      t /= d;
      return c * t * t * t * t * t + b;
    };

    Easing.easeOutQuint = function(t, b, c, d) {
      t = t / d - 1;
      return c * (t * t * t * t * t + 1) + b;
    };

    Easing.easeInOutQuint = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        return c / 2 * t * t * t * t * t + b;
      } else {
        t -= 2;
        return c / 2 * (t * t * t * t * t + 2) + b;
      }
    };

    Easing.easeOutInQuint = function(t, b, c, d) {
      t = t * 2 / d - 1;
      return c / 2 * (t * t * t * t * t + 1) + b;
    };

    Easing.easeInExpo = function(t, b, c, d) {
      return c * _pow(2, 10 * (t / d - 1)) + b;
    };

    Easing.easeOutExpo = function(t, b, c, d) {
      return c * (1 - _pow(2, -10 * t / d)) + b;
    };

    Easing.easeInOutExpo = function(t, b, c, d) {
      t = t * 2 / d - 1;
      if (t < 0) {
        return c / 2 * _pow(2, 10 * t) + b;
      } else {
        return c / 2 * (2 - _pow(2, -10 * t)) + b;
      }
    };

    Easing.easeOutInExpo = function(t, b, c, d) {
      t *= 2 / d;
      if (t === 1) {
        return c / 2 + b;
      } else if (t < 1) {
        return c / 2 * (1 - _pow(2, -10 * t)) + b;
      } else {
        return c / 2 * (1 + _pow(2, 10 * (t - 2))) + b;
      }
    };

    Easing.easeInSine = function(t, b, c, d) {
      return -c * (_cos(t / d * _PI_H) - 1) + b;
    };

    Easing.easeOutSine = function(t, b, c, d) {
      return c * _sin(t / d * _PI_H) + b;
    };

    Easing.easeInOutSine = function(t, b, c, d) {
      return -c / 2 * (_cos(_PI * t / d) - 1) + b;
    };

    Easing.easeOutInSine = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        return c / 2 * _sin(t * _PI_H) + b;
      } else {
        return -c / 2 * (_cos((t - 1) * _PI_H) - 2) + b;
      }
    };

    Easing.easeInCirc = function(t, b, c, d) {
      t /= d;
      return -c * (_sqrt(1 - t * t) - 1) + b;
    };

    Easing.easeOutCirc = function(t, b, c, d) {
      t = t / d - 1;
      return c * _sqrt(1 - t * t) + b;
    };

    Easing.easeInOutCirc = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        return -c / 2 * (_sqrt(1 - t * t) - 1) + b;
      } else {
        t -= 2;
        return c / 2 * (_sqrt(1 - t * t) + 1) + b;
      }
    };

    Easing.easeOutInCirc = function(t, b, c, d) {
      t = t * 2 / d - 1;
      if (t < 0) {
        return c / 2 * _sqrt(1 - t * t) + b;
      } else {
        return -c / 2 * (_sqrt(1 - t * t) - 2) + b;
      }
    };

    Easing.easeInBackWith = function(s) {
      if (s == null) s = 1.70158;
      return function(t, b, c, d) {
        var _s;
        _s = s;
        t /= d;
        return c * t * t * ((_s + 1) * t - _s) + b;
      };
    };

    Easing.easeInBack = Easing.easeInBackWith();

    Easing.easeOutBackWith = function(s) {
      if (s == null) s = 1.70158;
      return function(t, b, c, d) {
        var _s;
        _s = s;
        t = t / d - 1;
        return c * (t * t * ((_s + 1) * t + _s) + 1) + b;
      };
    };

    Easing.easeOutBack = Easing.easeOutBackWith();

    Easing.easeInOutBackWith = function(s) {
      if (s == null) s = 1.70158;
      return function(t, b, c, d) {
        var _s;
        _s = s * 1.525;
        t *= 2 / d;
        if (t < 1) {
          return c / 2 * (t * t * ((_s + 1) * t - _s)) + b;
        } else {
          t -= 2;
          return c / 2 * (t * t * ((_s + 1) * t + _s) + 2) + b;
        }
      };
    };

    Easing.easeInOutBack = Easing.easeInOutBackWith();

    Easing.easeOutInBackWith = function(s) {
      if (s == null) s = 1.70158;
      return function(t, b, c, d) {
        var _s;
        _s = s;
        t = t * 2 / d - 1;
        if (t < 0) {
          return c / 2 * (t * t * ((_s + 1) * t + _s) + 1) + b;
        } else {
          return c / 2 * (t * t * ((_s + 1) * t - _s) + 1) + b;
        }
      };
    };

    Easing.easeOutInBack = Easing.easeOutInBackWith();

    Easing.easeInBounce = function(t, b, c, d) {
      t = 1 - t / d;
      if (t < 0.36363636363636365) {
        return -c * (7.5625 * t * t - 1) + b;
      } else if (t < 0.7272727272727273) {
        t -= 0.5454545454545454;
        return -c * (7.5625 * t * t - 0.25) + b;
      } else if (t < 0.9090909090909091) {
        t -= 0.8181818181818182;
        return -c * (7.5625 * t * t - 0.0625) + b;
      } else {
        t -= 0.9545454545454546;
        return -c * (7.5625 * t * t - 0.015625) + b;
      }
    };

    Easing.easeOutBounce = function(t, b, c, d) {
      t /= d;
      if (t < 0.36363636363636365) {
        return c * (7.5625 * t * t) + b;
      } else if (t < 0.7272727272727273) {
        t -= 0.5454545454545454;
        return c * (7.5625 * t * t + 0.75) + b;
      } else if (t < 0.9090909090909091) {
        t -= 0.8181818181818182;
        return c * (7.5625 * t * t + 0.9375) + b;
      } else {
        t -= 0.9545454545454546;
        return c * (7.5625 * t * t + 0.984375) + b;
      }
    };

    Easing.easeInOutBounce = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        t = 1 - t;
        if (t < 0.36363636363636365) {
          return -c / 2 * (7.5625 * t * t - 1) + b;
        } else if (t < 0.7272727272727273) {
          t -= 0.5454545454545454;
          return -c / 2 * (7.5625 * t * t - 0.25) + b;
        } else if (t < 0.9090909090909091) {
          t -= 0.8181818181818182;
          return -c / 2 * (7.5625 * t * t - 0.0625) + b;
        } else {
          t -= 0.9545454545454546;
          return -c / 2 * (7.5625 * t * t - 0.015625) + b;
        }
      } else {
        t -= 1;
        if (t < 0.36363636363636365) {
          return c / 2 * (7.5625 * t * t + 1) + b;
        } else if (t < 0.7272727272727273) {
          t -= 0.5454545454545454;
          return c / 2 * (7.5625 * t * t + 1.75) + b;
        } else if (t < 0.9090909090909091) {
          t -= 0.8181818181818182;
          return c / 2 * (7.5625 * t * t + 1.9375) + b;
        } else {
          t -= 0.9545454545454546;
          return c / 2 * (7.5625 * t * t + 1.984375) + b;
        }
      }
    };

    Easing.easeOutInBounce = function(t, b, c, d) {
      t *= 2 / d;
      if (t < 1) {
        if (t < 0.36363636363636365) {
          return c / 2 * (7.5625 * t * t) + b;
        } else if (t < 0.7272727272727273) {
          t -= 0.5454545454545454;
          return c / 2 * (7.5625 * t * t + 0.75) + b;
        } else if (t < 0.9090909090909091) {
          t -= 0.8181818181818182;
          return c / 2 * (7.5625 * t * t + 0.9375) + b;
        } else {
          t -= 0.9545454545454546;
          return c / 2 * (7.5625 * t * t + 0.984375) + b;
        }
      } else {
        t = 2 - t;
        if (t < 0.36363636363636365) {
          return -c / 2 * (7.5625 * t * t - 2) + b;
        } else if (t < 0.7272727272727273) {
          t -= 0.5454545454545454;
          return -c / 2 * (7.5625 * t * t - 1.25) + b;
        } else if (t < 0.9090909090909091) {
          t -= 0.8181818181818182;
          return -c / 2 * (7.5625 * t * t - 1.0625) + b;
        } else {
          t -= 0.9545454545454546;
          return -c / 2 * (7.5625 * t * t - 1.015625) + b;
        }
      }
    };

    Easing.easeInElasticWith = function(a, p) {
      if (a == null) a = 0;
      if (p == null) p = 0;
      return function(t, b, c, d) {
        var s, _a, _p;
        _a = a;
        _p = p;
        t = t / d - 1;
        if (_p === 0) _p = d * 0.3;
        if (_a === 0 || _a < _abs(c)) {
          _a = c;
          s = _p / 4;
        } else {
          s = _p / _PI_D * _asin(c / _a);
        }
        return -_a * _pow(2, 10 * t) * _sin((t * d - s) * _PI_D / _p) + b;
      };
    };

    Easing.easeInElastic = Easing.easeInElasticWith();

    Easing.easeOutElasticWith = function(a, p) {
      if (a == null) a = 0;
      if (p == null) p = 0;
      return function(t, b, c, d) {
        var s, _a, _p;
        _a = a;
        _p = p;
        t /= d;
        if (_p === 0) _p = d * 0.3;
        if (_a === 0 || _a < _abs(c)) {
          _a = c;
          s = _p / 4;
        } else {
          s = _p / _PI_D * _asin(c / _a);
        }
        return _a * _pow(2, -10 * t) * _sin((t * d - s) * _PI_D / _p) + b + c;
      };
    };

    Easing.easeOutElastic = Easing.easeOutElasticWith();

    Easing.easeInOutElasticWith = function(a, p) {
      if (a == null) a = 0;
      if (p == null) p = 0;
      return function(t, b, c, d) {
        var s, _a, _p;
        _a = a;
        _p = p;
        t = t * 2 / d - 1;
        if (_p === 0) _p = d * 0.45;
        if (_a === 0 || _a < _abs(c)) {
          _a = c;
          s = _p / 4;
        } else {
          s = _p / _PI_D * _asin(c / _a);
        }
        if (t < 0) {
          return -_a / 2 * _pow(2, 10 * t) * _sin((t * d - s) * _PI_D / _p) + b;
        } else {
          return _a / 2 * _pow(2, -10 * t) * _sin((t * d - s) * _PI_D / _p) + b + c;
        }
      };
    };

    Easing.easeInOutElastic = Easing.easeInOutElasticWith();

    Easing.easeOutInElasticWith = function(a, p) {
      if (a == null) a = 0;
      if (p == null) p = 0;
      return function(t, b, c, d) {
        var s, _a, _p;
        _a = a;
        _p = p;
        t = t * 2 / d;
        c /= 2;
        if (_p === 0) _p = d * 0.3;
        if (_a === 0 || _a < _abs(c)) {
          _a = c;
          s = _p / 4;
        } else {
          s = _p / _PI_D * _asin(c / _a);
        }
        if (t < 1) {
          return _a * _pow(2, -10 * t) * _sin((t * d - s) * _PI_D / _p) + b + c;
        } else {
          t -= 2;
          return -_a * _pow(2, 10 * t) * _sin((t * d - s) * _PI_D / _p) + b + c;
        }
      };
    };

    Easing.easeOutInElastic = Easing.easeOutInElasticWith();

    return Easing;

  })();

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Junc;
  } else if (typeof define !== "undefined" && define !== null) {
    define(function() {
      return Junc;
    });
  } else if (typeof window !== "undefined" && window !== null) {
    if (window.mn == null) window.mn = {};
    if (window.mn.dsk == null) window.mn.dsk = {};
    window.mn.dsk.Junc = Junc;
    window.mn.dsk.Easing = Easing;
    window.mn.dsk.AnimationFrameTicker = AnimationFrameTicker;
  }

}).call(this);
