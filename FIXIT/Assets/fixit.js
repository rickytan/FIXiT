var FIXIT, global = this;
(function () {
  FIXIT = function (cls) {
    this.clsName = cls;
  };

  FIXIT.prototype.fixInstanceMethod = function (sel, func) {
    return _fixit_im(this.clsName, sel, func);
  };

  FIXIT.prototype.fixClassMethod = function (sel, func) {
    return __fixit_cm(this.clsName, sel, func);
  };

  Object.defineProperty(Object.prototype, '_c', {
    value: function (name) {
      if (this[name] instanceof Function) {
        return this[name].bind(this);
      } else {
        return function() {
          
        };
      }
    },
    configurable: false,
    enumerable: false
  });
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

  global.YES = true;
  global.NO = false;
}());
