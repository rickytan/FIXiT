!(function (Fixit, require) {
  require('UIColor, UIAlertView, UIApplication, UINavigationController, UIViewController, RTCustomModel');
  var fix = Fixit.fix('RTViewController');
  fix.instanceMethod('locationOf:atIndex:defaultValue:', function (locations, index, point) {
    var vc = this;
    if (isNil(vc)) {
      console.log(7);
    }
    vc = vc.navigationController;
    if (isNil(vc)) {
      console.log(11);
    }
    vc = vc.presentingViewController;
    if (isNil(vc)) {
      console.log(15);
    }
    vc = vc.title;
    if (isNil(vc)) {
      console.log(19);
    }
    this.button.frame = CGRectMake(100, 200, 120, 80);
    if (index > locations.length - 1) {
      this.button['setTitle:forState:']('out of bounds', 0);
      this.view.backgroundColor = UIColor.redColor;
      return point;
    }
    this.button['setTitle:forState:']('in bounds', 0);
    this.view.backgroundColor = UIColor.yellowColor;
    return locations[index];
  });

  var viewDidLoad = fix.instanceMethod('viewDidLoad', function () {
    viewDidLoad.apply(this, arguments);
    var that = this;
    dispatch_after(2, function () {
      that.button.removeFromSuperview;
      that.button = nil;
      RTCustomModel.new;
      RTCustomModel.model;
    });
  });
  fix.instanceMethod('_crash', function () {
    UIAlertView.alloc['initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:']('Instance', 'Yes, fixed!', undefined, 'ok', nil).show();
  });
  fix.classMethod('_crash', function () {
    UIAlertView.alloc['initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:']('Class', 'Yes, fixed!', undefined, 'ok', nil).show();
  });
  Fixit.fix('NSObject').instanceMethod('crashIt', function () {
    console.log(this);
  });

})(Fixit, require);
