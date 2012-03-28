(function() {
  var Actor, FunctionActor, GroupActor, Junc, ParallelActor, ParallelEachActor, SerialActor, SerialEachActor, WaitActor, _isArray, _slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  _slice = Array.prototype.slice;

  _isArray = Array.isArray;

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
      var _this = this;
      actor.root = this.root;
      actor.skip = function() {
        _this.local.index = _this.local.length;
        return _this._onComplete();
      };
      actor.global = this.global;
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

  SerialEachActor = (function(_super) {

    __extends(SerialEachActor, _super);

    function SerialEachActor(actor) {
      this.next = __bind(this.next, this);      SerialEachActor.__super__.constructor.call(this, [actor]);
    }

    SerialEachActor.prototype.clone = function() {
      return new SerialEachActor(this.__actors[0]);
    };

    SerialEachActor.prototype.start = function(_args) {
      var arg, i, _len, _ref;
      this._args = _args;
      this._actors = [];
      _ref = this._args;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        arg = _ref[i];
        this._actors[i] = this.__actors[0].clone();
      }
      this._storage = [];
      return SerialEachActor.__super__.start.call(this);
    };

    SerialEachActor.prototype.next = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this._storage[this.local.index] = args;
      return SerialEachActor.__super__.next.call(this);
    };

    SerialEachActor.prototype._onComplete = function() {
      return SerialEachActor.__super__._onComplete.call(this, this._storage);
    };

    SerialEachActor.prototype._act = function(actor) {
      SerialEachActor.__super__._act.call(this, actor, [this._args[this.local.index]]);
    };

    return SerialEachActor;

  })(SerialActor);

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

  module.exports = Junc;

}).call(this);
