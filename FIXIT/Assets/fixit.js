var global = this;
(function () {
  Object.defineProperty(Object.prototype, '_c', {
    value: function (name) {
      if (this[name] instanceof Function) {
        return this[name].bind(this);
      } else {
        return function () {
          var args = Array.prototype.slice.call(arguments);

          return _instanceCallMethod(this, name, args);
        }.bind(this);
      }
    },
    configurable: false,
    enumerable: false
  });

  global.makeProxiedFunction = function (target, method) {
    return function () {
      var args = Array.prototype.slice.call(arguments);
      return makeProxiedObject(_instanceCallMethod(target, method, args));
    };
  };

  global.makeProxiedObject = function (target) {
    if (target === undefined) {
      return;
    } else if (target.__target__ !== undefined) {
      return target;
    } else {
      return new Proxy(target, {
        get: function (target, key) {
          if (key === '__target__') {
            return target;
          } else if (key === '__proto__') {
            return Object.prototype;
          }
          return _valueForKey(target, key);
        },
        set: _setValueForKey,
        apply: function (target, thisArg, arguments) {
          return this;
        }
      });
    }
  };

  global.unproxyFunction = function (func) {
    return function () {
      var val = func.apply(this, arguments);
      console.log('called func', val);
      return (val && val.__target__) || val;
    };
  };
  /*
   if (global.console) {
   var jsLogger = console.log;
   global.console.log = function () {
   global._OC_log.apply(global, arguments);
   if (jsLogger) {
   jsLogger.apply(global.console, arguments);
   }
   }
   } else {
   global.console = {
   log: global._OC_log
   }
   }
   */
  global.YES = true;
  global.NO = false;
}());
