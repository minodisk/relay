(function() {
  var Actor, FunctionActor, GroupActor, Junc, ParallelActor, RepeatActor, SerialActor, WaitActor, _isArray, _slice,
    __slice = Array.prototype.slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  _slice = Array.prototype.slice;

  _isArray = Array.isArray;

  Junc = (function() {

    function Junc() {}

    Junc.sync = function(func) {
      return new FunctionActor(func, false);
    };

    Junc.async = function(func) {
      return new FunctionActor(func, true);
    };

    Junc.wait = function(delay) {
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
      return new RepeatActor(actor, repeatCount);
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

    function FunctionActor(func, async) {
      this.func = func;
      this.async = async;
      this.next = __bind(this.next, this);
      FunctionActor.__super__.constructor.call(this);
      if (typeof this.func !== 'function') {
        throw new TypeError('Arguments[0] of FunctionActor must be inspected Function.');
      }
    }

    FunctionActor.prototype.start = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      FunctionActor.__super__.start.call(this);
      this.func.apply(this, args);
      if (!this.async) this.next();
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
        if (!(actor instanceof Actor || actor === Junc.serial || actor === Junc.parallel)) {
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

    GroupActor.prototype.interrupt = function(actor) {};

    GroupActor.prototype._reset = function() {
      var actor, _i, _len, _ref;
      GroupActor.__super__._reset.call(this);
      this.local = {};
      this._dst = [];
      this.localIndex = 0;
      this.localLength = this._src.length;
      delete this.globalIndex;
      delete this.repeatIndex;
      delete this.repeatLength;
      if (this === this.root) this.globalIndex = 0;
      _ref = this._src;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        if (typeof actor._reset === "function") actor._reset();
      }
    };

    GroupActor.prototype._act = function(actor, args) {
      var _ref, _ref2;
      actor.root = this.root;
      if (!(actor instanceof RepeatActor)) actor.repeatRoot = this.repeatRoot;
      actor.global = this.global;
      actor.globalIndex = this.root.globalIndex;
      actor.repeatIndex = (_ref = this.repeatRoot) != null ? _ref.repeatIndex : void 0;
      actor.repeatLength = (_ref2 = this.repeatRoot) != null ? _ref2.repeatLength : void 0;
      if (actor instanceof GroupActor) {
        return actor.start(args);
      } else {
        actor.local = this.local;
        actor.localIndex = this.localIndex;
        actor.localLength = this.localLength;
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
      if (this.localIndex < this.localLength) {
        this._act(this._getCurrentActor(args), args);
        this._onStart();
      }
      return this;
    };

    SerialActor.prototype.next = function() {
      var actor, args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      actor = this._dst[this.localIndex];
      this.localIndex++;
      if (actor instanceof GroupActor) {
        this.globalIndex = this.root.globalIndex;
      } else {
        this.root.globalIndex++;
      }
      if (this.localIndex < this.localLength) {
        actor = this._getCurrentActor(args);
        this._act(actor, args);
      } else if (this.localIndex === this.localLength) {
        this._onComplete(args);
      }
      return this;
    };

    SerialActor.prototype._getCurrentActor = function(args) {
      var actor;
      actor = this._src[this.localIndex];
      if (actor === Junc.serial || actor === Junc.parallel) {
        actor = actor.apply(Junc, args);
        while (args.length) {
          args.pop();
        }
      }
      this._dst[this.localIndex] = actor;
      return actor;
    };

    SerialActor.prototype._act = function(actor, args) {
      actor.onComplete = this.next;
      return SerialActor.__super__._act.call(this, actor, args);
    };

    return SerialActor;

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
      this.repeatIndex++;
      return RepeatActor.__super__.next.call(this);
    };

    RepeatActor.prototype._reset = function() {
      RepeatActor.__super__._reset.call(this);
      this.repeatIndex = 0;
      return this.repeatLength = this._src.length;
    };

    RepeatActor.prototype._act = function(actor, args) {
      return RepeatActor.__super__._act.call(this, actor, args);
    };

    return RepeatActor;

  })(SerialActor);

  ParallelActor = (function(_super) {

    __extends(ParallelActor, _super);

    function ParallelActor(actors) {
      this.next = __bind(this.next, this);      ParallelActor.__super__.constructor.call(this, actors);
      this.argsStorage = [];
    }

    ParallelActor.prototype.start = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ParallelActor.__super__.start.call(this);
      if (this.localIndex < this.localLength) {
        this._act(args);
        this._onStart();
      }
      return this;
    };

    ParallelActor.prototype.next = function() {
      var args, i,
        _this = this;
      i = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.argsStorage[i] = args;
      setTimeout((function() {
        _this.localIndex++;
        _this.root.globalIndex++;
        if (_this.localIndex >= _this.localLength) {
          _this.localIndex = _this.localLength;
          return _this._onComplete(_this.argsStorage);
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

  module.exports = Junc;

}).call(this);
