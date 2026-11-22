# FIXiT

[![Swift Package](https://github.com/rickytan/FIXiT/actions/workflows/swift-package.yml/badge.svg)](https://github.com/rickytan/FIXiT/actions/workflows/swift-package.yml)
[![Version](https://img.shields.io/cocoapods/v/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)
[![License](https://img.shields.io/cocoapods/l/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)
[![Platform](https://img.shields.io/cocoapods/p/FIXiT.svg?style=flat)](https://cocoapods.org/pods/FIXiT)

## 简介
此项目可以理解为 **JS** 版的 **[Aspect](https://github.com/steipete/Aspects)**

## 用法示例（快速入手）
### 修复已有方法的 Bug
OC 中定义了类型：
```objc

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
        return locations[index];    
        // 或者调原实现 
        return originMethod.apply(this, arguments);
        // 等价于
        return originMethod.call(this, locations, index, point);
    }
    return point;   // 这里的 point 会变为 NSValue，直接返回即可
});
```
### 在原有实现上添加行为
已有的 OC 类定义：
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
添加 JS 文件以添加行为：
```javascript
require('UIAlertView, UIColor');
var fix = Fixit.fix('MyViewController');
var originViewDidLoad = fix.instanceMethod('viewDidLoad', function () {
    // 先调原实现
    originViewDidLoad.apply(this, arguments);
    
    this.view.backgroundColor = UIColor.yellowColor;
    // 或者
    this.view['setBackgroundColor:'](UIColor.yellowColor);
    
    // [] 取 JS 的属性或方法，当无参数时是属性，有参数时是方法
    var button = this['_button'];   // 与 this._button 等价
    // button 变量是 nil 安全的，当然也可以判断一下，使用 isNil 函数，
    // 而不能 if (button == nil)，或者 if (button)。
    // 所有不能转为 JS 对象的 OC 对象在 JS 代码中都是一个代理对象（Proxy）
    if (!isNil(button)) {
        // 调用时参数需要与 OC 中对应
        button['setTitle:forState:']('test title', 0);
    }
    
    // 创建一个弹窗，注意使用 nil，而不是 null
    var that = this;
    dispatch_after(2, function() {
        // 注意 JS context 的变化，这里的 this 已经不是 MyViewController 了
        UIAlertView.alloc['initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:'](that.title, 'message!!!', nil, 'ok', nil).show();
    });
});
```

## Requirements

* Xcode 9+ (Xcode 12+ for Swift Package Manager)
* iOS 10+

## Installation

### Swift Package Manager

In Xcode, choose **File > Add Package Dependencies** and enter
`https://github.com/rickytan/FIXiT.git`. Select the `master` branch until a
release containing the Swift package is available, then add the `FIXiT`
product to your iOS target.

For a package manifest:

```swift
dependencies: [
    .package(url: "https://github.com/rickytan/FIXiT.git", .branch("master"))
],
targets: [
    .target(name: "YourTarget", dependencies: [
        .product(name: "FIXiT", package: "FIXiT")
    ])
]
```

Import the library with `import FIXiT` in Swift or `@import FIXiT;` in
Objective-C.

FIXiT loads `FIXiT.bundle` from the main app bundle. Swift Package Manager puts
it inside its own resource bundle, so add a **Run Script** phase to the app
target after **Copy Bundle Resources**:

```sh
set -eu
/usr/bin/ditto \
  "${BUILT_PRODUCTS_DIR}/FIXiT_FIXiT.bundle/FIXiT.bundle" \
  "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/FIXiT.bundle"
```

Add both the directory and its JavaScript file to the phase's input files:

```
$(BUILT_PRODUCTS_DIR)/FIXiT_FIXiT.bundle/FIXiT.bundle
$(BUILT_PRODUCTS_DIR)/FIXiT_FIXiT.bundle/FIXiT.bundle/fixit.js
```

Add both the destination directory and file to its output files:

```
$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/FIXiT.bundle
$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/FIXiT.bundle/fixit.js
```

The explicit file paths allow Xcode's user-script sandbox to copy the resource.
The script phase is required; without it, FIXiT cannot find its JavaScript at
runtime.

### CocoaPods

FIXiT is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FIXiT'
```

## Author

rickytan, ricky.tan.xin@gmail.com

## License

FIXIT is available under the MIT license. See the LICENSE file for more info.
