(function() {
  var Actor, EachActor, FunctionActor, GroupActor, Junc, ParallelActor, RepeatActor, SerialActor, WaitActor, _isArray, _slice,
    __slice = Array.prototype.slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  _slice = Array.prototype.slice;

  _isArray = Array.isArray;

  Junc = (function() {

    function Junc() {}

    Junc.func = function(func) {
      var len, req;
      if ((len = arguments.length) !== (req = 1)) {
        throw new TypeError("Junc.func() takes exactly " + req + " argument (" + len + " given)");
      }
      return new FunctionActor(func);
    };

    Junc.wait = function(delay) {
      var len, req;
      if ((len = arguments.length) !== (req = 1)) {
        throw new TypeError("Junc.wait() takes exactly " + req + " argument (" + len + " given)");
      }
      return new WaitActor(delay);
    };

    Junc.serial = function() {
      var actors;
      actors = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (_isArray(actors[0])) actors = actors[0];
      return new SerialActor(actors);
    };

    Junc.parallel = function() {
      var actors;
      actors = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (_isArray(actors[0])) actors = actors[0];
      return new ParallelActor(actors);
    };

    Junc.repeat = function(actor, repeatCount) {
      var len, req;
      if ((len = arguments.length) !== (req = 2)) {
        throw new TypeError("Junc.repeat() takes exactly " + req + " argument (" + len + " given)");
      }
      return new RepeatActor(actor, repeatCount);
    };

    Junc.each = function(actor) {
      var len, req;
      if ((len = arguments.length) !== (req = 1)) {
        throw new TypeError("Junc.each() takes exactly " + req + " argument (" + len + " given)");
      }
      return new EachActor(actor);
    };

    return Junc;

  })();

  Actor = (function() {

    function Actor() {
      this.root = this;
    }

    Actor.prototype.start = function() {
      if (this._running) this.stop();
      this._reset();
      this._running = true;
      return this;
    };

    Actor.prototype.stop = function() {
      this._running = false;
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
      if (this._running) {
        this._running = false;
        return (_ref = this.onComplete) != null ? _ref.apply(this, args) : void 0;
      }
    };

    return Actor;

  })();

  FunctionActor = (function(_super) {

    __extends(FunctionActor, _super);

    function FunctionActor(func) {
      this.func = func;
      this.next = __bind(this.next, this);
      FunctionActor.__super__.constructor.call(this);
      if (typeof this.func !== 'function') {
        throw new TypeError('new FunctionActor(func) func must be inspected Function.');
      }
    }

    FunctionActor.prototype.start = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      FunctionActor.__super__.start.call(this);
      this.func.apply(this, args);
      return this;
    };

    FunctionActor.prototype.next = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this._onComplete(args);
      return this;
    };

    return FunctionActor;

  })(Actor);

  WaitActor = (function(_super) {

    __extends(WaitActor, _super);

    function WaitActor(delay) {
      if (isNaN(delay)) {
        throw new TypeError('new WaitActor(delay) delay must be inspected Number.');
      }
      WaitActor.__super__.constructor.call(this, (function() {
        return setTimeout(this.next, delay);
      }), null, true);
    }

    return WaitActor;

  })(FunctionActor);

  GroupActor = (function(_super) {

    __extends(GroupActor, _super);

    function GroupActor(actors) {
      var actor, _i, _len;
      GroupActor.__super__.constructor.call(this);
      for (_i = 0, _len = actors.length; _i < _len; _i++) {
        actor = actors[_i];
        if (!(actor instanceof Actor)) {
          throw new TypeError('Arguments[0] of GroupActor must be inspected Array of Actor.');
        }
      }
      this._src = actors;
    }

    GroupActor.prototype.stop = function() {
      var actor, _i, _len, _ref;
      GroupActor.__super__.stop.call(this);
      _ref = this._dst;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        if (actor instanceof Actor) actor.stop();
      }
      return this;
    };

    GroupActor.prototype._reset = function() {
      var actor, _i, _len, _ref;
      GroupActor.__super__._reset.call(this);
      this._dst = [];
      this.local = {
        index: 0,
        length: this._src.length
      };
      if (this === this.root) this.global.index = 0;
      _ref = this._src;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        if (typeof actor._reset === "function") actor._reset();
      }
    };

    GroupActor.prototype._act = function(actor, args) {
      var _ref,
        _this = this;
      if (this.local.index < this.local.length) {
        actor.root = this.root;
        actor.skip = function() {
          _this.local.index = _this.local.length;
          return _this._onComplete();
        };
        if (!(actor instanceof RepeatActor)) actor.repeatRoot = this.repeatRoot;
        actor.global = this.global;
        actor.repeat = (_ref = this.repeatRoot) != null ? _ref.repeat : void 0;
        if (!(actor instanceof GroupActor)) actor.local = this.local;
        return actor.start.apply(actor, args);
      }
    };

    return GroupActor;

  })(Actor);

  SerialActor = (function(_super) {

    __extends(SerialActor, _super);

    function SerialActor(actors) {
      this.next = __bind(this.next, this);      SerialActor.__super__.constructor.call(this, actors);
    }

    SerialActor.prototype.start = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      SerialActor.__super__.start.call(this);
      if (this.local.index < this.local.length) {
        this._act(this._getCurrentActor(args), args);
        this._onStart();
      }
      return this;
    };

    SerialActor.prototype.next = function() {
      var actor, args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      actor = this._dst[this.local.index];
      this.local.index++;
      if (actor instanceof GroupActor) {
        this.global.index = this.root.global.index;
      } else {
        this.root.global.index++;
      }
      if (this.local.index < this.local.length) {
        this._act(this._getCurrentActor(args), args);
      } else if (this.local.index === this.local.length) {
        this._onComplete(args);
      }
      return this;
    };

    SerialActor.prototype._getCurrentActor = function(args) {
      var actor;
      actor = this._src[this.local.index];
      this._dst[this.local.index] = actor;
      return actor;
    };

    SerialActor.prototype._act = function(actor, args) {
      actor.onComplete = this.next;
      return SerialActor.__super__._act.call(this, actor, args);
    };

    return SerialActor;

  })(GroupActor);

  ParallelActor = (function(_super) {

    __extends(ParallelActor, _super);

    function ParallelActor(actors) {
      this.next = __bind(this.next, this);      ParallelActor.__super__.constructor.call(this, actors);
    }

    ParallelActor.prototype.start = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ParallelActor.__super__.start.call(this);
      this._storage = [];
      if (this.local.index < this.local.length) {
        this._act(args);
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

    ParallelActor.prototype._act = function(args) {
      var actor, i, _len, _ref, _results,
        _this = this;
      _ref = this._src;
      _results = [];
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
        _results.push(ParallelActor.__super__._act.call(this, actor, args));
      }
      return _results;
    };

    return ParallelActor;

  })(GroupActor);

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
        length: this._src.length
      };
    };

    return RepeatActor;

  })(SerialActor);

  EachActor = (function(_super) {

    __extends(EachActor, _super);

    function EachActor(_actor) {
      this._actor = _actor;
      this.next = __bind(this.next, this);
      EachActor.__super__.constructor.call(this);
    }

    EachActor.prototype.start = function(_array) {
      this._array = _array;
      EachActor.__super__.start.call(this);
      this._storage = [];
      this._act();
      this._onStart();
      return this;
    };

    EachActor.prototype._reset = function() {
      var _base;
      EachActor.__super__._reset.call(this);
      this._dst = [];
      this.local = {
        index: 0,
        length: this._array.length
      };
      if (this === this.root) this.global.index = 0;
      if (typeof (_base = this._actor)._reset === "function") _base._reset();
    };

    EachActor.prototype.next = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this._storage[this.local.index] = args;
      this.local.index++;
      if (this._actor instanceof GroupActor) {
        this.global.index = this.root.global.index;
      } else {
        this.root.global.index++;
      }
      if (this.local.index < this.local.length) {
        this._act();
      } else if (this.local.index === this.local.length) {
        this._onComplete(this._storage);
      }
      return this;
    };

    EachActor.prototype._act = function() {
      var _ref,
        _this = this;
      this._actor.onComplete = this.next;
      this._actor.root = this.root;
      this._actor.skip = function() {
        _this.local.index = _this.local.length;
        return _this._onComplete();
      };
      if (!(this._actor instanceof RepeatActor)) {
        this._actor.repeatRoot = this.repeatRoot;
      }
      this._actor.global = this.global;
      this._actor.repeat = (_ref = this.repeatRoot) != null ? _ref.repeat : void 0;
      if (!(this._actor instanceof GroupActor)) this._actor.local = this.local;
      this._actor.start.call(this._actor, this._array[this.local.index], this.local.index, this._array);
    };

    return EachActor;

  })(Actor);

  module.exports = Junc;

}).call(this);
