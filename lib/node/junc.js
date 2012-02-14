(function() {
  var Actor, FunctionActor, GroupActor, Junc, ParallelActor, RepeatActor, SerialActor, WaitActor, _slice,
    __slice = Array.prototype.slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  _slice = Array.prototype.slice;

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
      return new SerialActor(actors);
    };

    Junc.parallel = function() {
      var actors;
      actors = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return new ParallelActor(actors);
    };

    Junc.repeat = function(actor, repeatCount) {
      return new RepeatActor(actor, repeatCount);
    };

    return Junc;

  })();

  Actor = (function() {

    function Actor() {
      this.params = {};
    }

    Actor.prototype.start = function() {
      if (this._running) this.stop();
      this._reset();
      return this._running = true;
    };

    Actor.prototype.stop = function() {
      return this._running = false;
    };

    Actor.prototype._reset = function() {};

    Actor.prototype._onStart = function() {
      return typeof this.onStart === "function" ? this.onStart(this) : void 0;
    };

    Actor.prototype._onComplete = function() {
      if (this._running) {
        this._running = false;
        return typeof this.onComplete === "function" ? this.onComplete() : void 0;
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

    FunctionActor.prototype.start = function(args) {
      FunctionActor.__super__.start.call(this);
      this.func.apply(this, args);
      if (!this.async) return this.next();
    };

    FunctionActor.prototype.next = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return typeof this.onComplete === "function" ? this.onComplete(args) : void 0;
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
        if (!(actor instanceof Actor)) {
          throw new TypeError('Arguments[0] of GroupActor must be inspected Array of Actor.');
        }
      }
      this._actors = actors;
      this.currentPhase = 0;
      this.totalPhase = actors.length;
      this.userData = {};
    }

    GroupActor.prototype.stop = function() {
      var actor, _i, _len, _ref;
      GroupActor.__super__.stop.call(this);
      _ref = this._actors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        if (actor instanceof Actor) actor.stop();
      }
    };

    GroupActor.prototype._reset = function() {
      var actor, _i, _len, _ref;
      GroupActor.__super__._reset.call(this);
      this.currentPhase = 0;
      _ref = this._actors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
        actor._reset();
      }
    };

    GroupActor.prototype._act = function(actor, args) {
      if (this.onError) actor.onError = this.onError;
      actor.onComplete = this.next;
      actor.params = this.params;
      if (actor instanceof GroupActor) {
        return actor.start(args);
      } else {
        console.log('_act', this.currentPhase, args);
        actor.currentPhase = this.currentPhase;
        actor.totalPhase = this.totalPhase;
        return actor.start(args);
      }
    };

    return GroupActor;

  })(Actor);

  SerialActor = (function(_super) {

    __extends(SerialActor, _super);

    function SerialActor(actors) {
      this.next = __bind(this.next, this);      SerialActor.__super__.constructor.call(this, actors);
    }

    SerialActor.prototype.start = function(args) {
      SerialActor.__super__.start.call(this);
      if (this.currentPhase < this.totalPhase) {
        this._act(this._actors[this.currentPhase], args);
        this._onStart();
      }
    };

    SerialActor.prototype.next = function(args) {
      var _ref;
      console.log('next', this.currentPhase, args);
      this.params = (_ref = this._actors[this.currentPhase]) != null ? _ref.params : void 0;
      if (++this.currentPhase < this.totalPhase) {
        this._act(this._actors[this.currentPhase], args);
      } else if (this.currentPhase === this.totalPhase) {
        this._onComplete();
      } else {
        this.currentPhase = this.totalPhase;
      }
    };

    return SerialActor;

  })(GroupActor);

  ParallelActor = (function(_super) {

    __extends(ParallelActor, _super);

    function ParallelActor(actors) {
      this.next = __bind(this.next, this);      ParallelActor.__super__.constructor.call(this, actors);
    }

    ParallelActor.prototype.start = function(args) {
      ParallelActor.__super__.start.call(this);
      if (this.currentPhase < this.totalPhase) {
        this._act(args);
        this._onStart();
      }
    };

    ParallelActor.prototype.next = function(args) {
      var _this = this;
      setTimeout((function() {
        if (++_this.currentPhase >= _this.totalPhase) {
          _this.currentPhase = _this.totalPhase;
          return _this._onComplete(args);
        }
      }), 0);
    };

    ParallelActor.prototype._act = function(args) {
      var actor, _i, _len, _ref, _results;
      _ref = this._actors;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        actor = _ref[_i];
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
    }

    return RepeatActor;

  })(SerialActor);

  module.exports = Junc;

}).call(this);