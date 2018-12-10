//
//  JSValue+FIXIT.m
//  FIXIT
//
//  Created by ricky on 2018/12/9.
//

#import <objc/runtime.h>

#import "FIXiT.h"
#import "JSValue+FIXiT.h"

@implementation JSValue (FIXiT)

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(toObject)), class_getInstanceMethod(self, @selector(__fixit_toObject)));
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(toObjectOfClass:)), class_getInstanceMethod(self, @selector(__fixit_toObjectOfClass:)));
    });
}

- (id)__fixit_toObject
{
    if (self.context != [FIXiT context]) {
        return [self __fixit_toObject];
    }

    if (self.isUndefined) {
        return nil;
    }
    if (self.isNull) {
        return [NSNull null];
    }

    JSValue *target = self[@"__target__"];
    if (target.isUndefined) {
        return [self __fixit_toObject];
    }
    return target.toObject;
}

- (id)__fixit_toObjectOfClass:(Class)expectedClass
{
    if (self.context != [FIXiT context]) {
        return [self __fixit_toObjectOfClass:expectedClass];
    }

    if (self.isUndefined) {
        return nil;
    }

    if (self.isNull) {
        return [NSNull null];
    }

    JSValue *target = self[@"__target__"];
    if (target.isUndefined) {
        return [self __fixit_toObjectOfClass:expectedClass];
    }
    return [target toObjectOfClass:expectedClass];
}

- (BOOL)fixit_isNil
{
    return [[FIXiT context].globalObject invokeMethod:@"isNil" withArguments:@[self]].toBool;
}

@end
