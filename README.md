# FIXiT

[![CI Status](https://img.shields.io/travis/rickytan/FIXiT.svg?style=flat)](https://travis-ci.org/rickytan/FIXiT)
[![Version](https://img.shields.io/cocoapods/v/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)
[![License](https://img.shields.io/cocoapods/l/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)
[![Platform](https://img.shields.io/cocoapods/p/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)

## Example
### 修复已有方法的 Bug
OC 中定义了类型：
```objc
@interface NSObject (Crash)
- (void)crashIt;
@end

@implementation NSObject (Crash)

- (void)crashIt
{
  NSLog(@"%@", @[][1]);
}

- (CGPoint)locationOf:(NSArray <NSValue *> *)locations
              atIndex:(NSInteger)index
         defaultValue:(CGPoint)point
{
  return locations[index].CGPointValue;
}

@end
```
添加 JS 文件以修复：
```javascript
var fix = Fixit.fix('NSObject');
fix.instanceMethod('crashIt', function () {
  
});
// fix.instanceMethod 返回原实现
var originMethod = fix.instanceMethod('locationOf:atIndex:defaultValue:', function (locations, index, point) {
    // 此函数中的 this 就是 OC 的实例
    if (index < locations.length) {
        return locations[index];    // 或者调原实现 return originMethod.apply(this, arguments);
    }
    return point;   // 这里的 point 会变为 NSValue，直接返回即可
});
```
### 在原有实现上添加行为
```objc
@implementation MyViewController
{
    UIButton    * _button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ...
}
```
```javascript
require('UIAlertView');
var fix = Fixit.fix('MyViewController');
var originViewDidLoad = fix.instanceMethod('viewDidLoad', function () {
    // 先调原实现
    originViewDidLoad.apply(this, arguments);
    
    // [] 取 JS 的属性或方法，当无参数时是属性，有参数时是方法
    var button = this['_button'];   // 与 this._button 等价
    // 调用时参数需要与 OC 中对应
    button['setTitle:forState:']('test title', 0);
    
    // 创建一个弹窗，注意使用 nil，而不是 null
    UIAlertView.alloc['initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:']('Title', 'message!!!', nil, 'ok', nil).show();
});
```

## Requirements

## Installation

FIXiT is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FIXiT'
```

## Author

rickytan, ricky.tan.xin@gmail.com

## License

FIXIT is available under the MIT license. See the LICENSE file for more info.
