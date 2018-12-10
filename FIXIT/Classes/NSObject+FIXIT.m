//
//  NSObject+FIXIT.m
//  FIXIT
//
//  Created by ricky on 2018/12/10.
//

#import <objc/runtime.h>

#import "NSObject+FIXIT.h"


@implementation NSObject (FIXIT)

+ (NSMutableDictionary<NSString *,NSMutableDictionary<NSString *, JSValue *> *> *)fixit_classAssociatedJSFunctions
{
    static dispatch_once_t onceToken;
    static NSMutableDictionary<NSString *,NSMutableDictionary<NSString *, JSValue *> *> * _classAssociatedJSFunctions;
    dispatch_once(&onceToken, ^{
        _classAssociatedJSFunctions = [NSMutableDictionary dictionary];
    });
    return _classAssociatedJSFunctions;
}

- (void)fixit_setJSFunction:(JSValue *)function forSelector:(SEL)selector
{
    @synchronized (self) {
        NSMutableDictionary<NSString *, JSValue *> * dict = [self.class fixit_classAssociatedJSFunctions][NSStringFromClass(self.class)];
        if (!dict) {
            dict = [NSMutableDictionary dictionary];
            [self.class fixit_classAssociatedJSFunctions][NSStringFromClass(self.class)] = dict;
        }
        dict[NSStringFromSelector(selector)] = function;
    }
}

- (JSValue *)fixit_JSFunctionForSelector:(SEL)selector
{
    Class cls = [self class];
    JSValue *function = nil;
    while (!function && cls) {
        function = [self.class fixit_classAssociatedJSFunctions][NSStringFromClass(cls)][NSStringFromSelector(selector)];
        cls = [cls superclass];
    }
    return function;
}

@end
