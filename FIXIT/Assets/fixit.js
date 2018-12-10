var global = this;
(function () {
  global.nil = global.Nil = Symbol('nil');
  global.nilToNull = function (o) {
    if (o === nil) {
      return null;
    }
    return o;
  };
  global.nullToNil = function (o) {
    if (o === null) {
      return nil;
    }
    return o;
  };

  global.makeProxiedFunction = function (target, method) {
    return function () {
      var args = Array.prototype.slice.call(arguments);
      return makeProxiedObject(_instanceCallMethod(target, method, args));
    };
  };

  global.makeProxiedObject = function (target) {
    if (target === undefined) {
      return;
    } else if (target === null) {
      target = nil;
    }

    if (target.__target__ !== undefined) {
      return target;
    } else {
      var o = function () {};
      o.__target__ = target;
      return new Proxy(o, {
        get: function (target, key) {
          var obj = target.__target__;
          if (key === '__target__') {
            return obj;
          } else if (key === '__proto__') {
            return Object.prototype;
          } else if (typeof key === 'symbol') {
            return obj[key];
          }

          return _valueForKey(nilToNull(obj), key);
        },
        set: function (target, key, value) {
          _setValueForKey(target.__target__, key, value);
        },
        apply: function (target, thisArg, arguments) {
          return makeProxiedObject(target.__target__);
        }
      });
    }
  };

  global.unproxyFunction = function (func) {
    return function () {
      var val = func.apply(this, arguments);
      return unproxyObject(val);
    };
  };

  global.unproxyObject = function (obj) {
    obj = (obj && obj.__target__) || obj;
    return nilToNull(obj);
  };

  if (global.console) {
    var jsLogger = console.log;
    global.console.log = function () {
      for (var i = 0; i < arguments.length; ++i) {
        arguments[i] = unproxyObject(arguments[i]);
      }
      if (jsLogger) {
        jsLogger.apply(global.console, arguments);
      }
      global._log.apply(global, arguments);
    };
  } else {
    global.console = {
      log: global._log
    };
  }

  global.YES = true;
  global.NO = false;
}());
