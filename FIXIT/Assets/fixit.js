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

  global.proxyFunction = function (target, method) {
    return function () {
      var args = Array.prototype.slice.call(arguments);
      return _instanceCallMethod(target, method, args);
    };
  };

  var _handler = {
    get: function (target, key) {
      return new Proxy(_valueForKey.apply(this, arguments), _handler);
    },
    set: _setValueForKey
  };

  global.proxyObject = function (target) {
    return new Proxy(target, _handler);
  };


  if (global.console) {
    var jsLogger = console.log;
    global.console.log = function () {
      global._OC_log.apply(global, arguments);
      if (jsLogger) {
        jsLogger.apply(global.console, arguments);
      }
    };
  } else {
    global.console = {
      log: global._OC_log
    };
  }

  global.YES = true;
  global.NO = false;
}());
