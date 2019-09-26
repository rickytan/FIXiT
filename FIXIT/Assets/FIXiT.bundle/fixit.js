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
  global.isNil = function (o) {
    return !o || o === nil || o.__target__ === nil;
  };

  global.makeProxiedFunction = function (method) {
    return function () {
      return makeProxiedObject(_instanceCallMethod(this, method, arguments));
    };
  };

  global.makeProxiedObject = function (target) {
    if (target === undefined || target === null) {
      target = nil;
    }

    if (target.__target__ !== undefined) {
      return target;
    } else {
      var o = function () {};
      o.__target__ = target;
      return new Proxy(o, {
        get: function (target, key) {
          if (target.hasOwnProperty(key)) {
            return target[key];
          }
          var obj = target.__target__;
          if (obj.hasOwnProperty(key)) {
            return obj[key];
          }

          return _valueForKey(nilToNull(obj), key);
        },
        set: function (target, key, value) {
          _setValueForKey(target.__target__, key, value);
        },
        apply: function (target, thisArg, arguments) {
          return makeProxiedObject(target.__target__.apply(thisArg, arguments));
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
