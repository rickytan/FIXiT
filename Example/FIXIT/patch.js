!(function (Fixit, require) {
  require('UIColor');
  var fix = Fixit.fix('RTViewController');
  var origin = fix.instanceMethod('locationOf:atIndex:defaultValue:', function (locations, index, point) {
    var vc = this.navigationController.presentingViewController.title;
    console.log(vc, this.title);
    this.button().frame = CGRectMake(100, 200, 120, 80);
    if (index > locations.length - 1) {
      this.button['setTitle:forState:']('out of bounds', 0);
      this.view.backgroundColor = UIColor.redColor;
      return point;
    }
    this.button['setTitle:forState:']('in bounds', 0);
    this.view.backgroundColor = UIColor.yellowColor;
    return locations[index];
  });
  Fixit.fix('NSObject').instanceMethod('crashIt', function () {
    console.log(this);
  });

})(Fixit, require);