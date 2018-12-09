//
//  JSValue+FIXIT.m
//  FIXIT
//
//  Created by ricky on 2018/12/9.
//

#import <objc/runtime.h>

#import "FIXIT.h"
#import "JSValue+FIXIT.h"

@implementation JSValue (FIXIT)

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        method_exchangeImplementations(class_getClassMethod(self, @selector(valueWithObject:inContext:)), class_getClassMethod(self, @selector(__fixit_valueWithObject:inContext:)));
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(toObject)), class_getInstanceMethod(self, @selector(__fixit_toObject)));
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(toObjectOfClass:)), class_getInstanceMethod(self, @selector(__fixit_toObjectOfClass:)));
    });
}

//+ (JSValue *)__fixit_valueWithObject:(id)value inContext:(JSContext *)context
//{
//    if (context != [FIXIT context]) {
//        return [self __fixit_valueWithObject:value inContext:context];
//    }
//    return [context.globalObject[@"makeProxiedObject"] callWithArguments:@[value ?: [NSNull null]]];
//}

- (id)__fixit_toObject
{
    if (self.isUndefined) {
        return nil;
    }

    JSValue *target = self[@"__target__"];
    if (target.isUndefined) {
        return [self __fixit_toObject];
    }
    return target.toObject;
}

- (id)__fixit_toObjectOfClass:(Class)expectedClass
{
    if (self.isUndefined) {
        return nil;
    }

    JSValue *target = self[@"__target__"];
    if (target.isUndefined) {
        return [self __fixit_toObjectOfClass:expectedClass];
    }
    return target.toObject;
}

@end
