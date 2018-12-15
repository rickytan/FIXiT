# FIXiT

[![CI Status](https://img.shields.io/travis/rickytan/FIXiT.svg?style=flat)](https://travis-ci.org/rickytan/FIXiT)
[![Version](https://img.shields.io/cocoapods/v/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)
[![License](https://img.shields.io/cocoapods/l/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)
[![Platform](https://img.shields.io/cocoapods/p/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)

## Example

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
    return point;
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
