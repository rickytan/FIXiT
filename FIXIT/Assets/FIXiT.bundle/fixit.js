var global = this;
(function () {
  global.nil = global.Nil = Symbol("nil");
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

  function isObject(obj) {
    let type = typeof obj;
    return type === "function" || (type === "object" && !!obj);
  }
  function replaceProxy(obj) {
    if (obj.__target__) {
      return obj.__target__;
    } else if (Array.isArray(obj)) {
      return obj.map(function (v) {
        return replaceProxy(v);
      });
    } else if (isObject(obj)) {
      var o = Object.create({});
      for (var p in obj) {
        if (obj.hasOwnProperty(p)) {
          o[p] = replaceProxy(obj[p]);
        }
      }
      return o;
    } else {
      return obj;
    }
  }

  global.makeProxiedFunction = function (method) {
    let selector = method;
    return function () {
      for (var i = 0; i < arguments.length; ++i) {
        arguments[i] = replaceProxy(arguments[i]);
      }
      return makeProxiedObject(_instanceCallMethod(this, selector, arguments));
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
          _setValueForKey(target.__target__, key, replaceProxy(value));
        },
        apply: function (target, thisArg, arguments) {
          if (typeof target.__target__ === "function") {
            return makeProxiedObject(
              target.__target__.apply(thisArg, arguments)
            );
          }
          return makeProxiedObject(null);
        },
      });
    }
  };

  global.unproxyFunction = function (func) {
    return function () {
      let val = func.apply(this, arguments);
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
      log: global._log,
    };
  }

  global.YES = true;
  global.NO = false;
})();
