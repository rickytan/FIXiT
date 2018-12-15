//
//  NSObject+FIXIT.m
//  FIXIT
//
//  Created by ricky on 2018/12/10.
//

#import <objc/runtime.h>
#include <map>

#import "NSObject+FIXiT.h"

typedef std::pair<JSValue *, JSValue *> MethodPair;
static std::map<Class, std::map<SEL, MethodPair> > _classAssociatedJSFunctions;

@implementation NSObject (FIXiT)

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

- (void)fixit_setJSFunction:(JSValue *)function forSelector:(SEL)selector isClassMethod:(BOOL)classMethod
{
    @synchronized (self) {
        if (classMethod) {
            _classAssociatedJSFunctions[self.class][selector].first = function;
        }
        else {
            _classAssociatedJSFunctions[self.class][selector].second = function;
        }
    }
}

+ (JSValue *)fixit_JSFunctionForSelector:(SEL)selector
{
    Class cls = self;
    JSValue *function = nil;
    while (!function && cls) {
        function = _classAssociatedJSFunctions[cls][selector].first;
        cls = [cls superclass];
    }
    return function;
}

- (JSValue *)fixit_JSFunctionForSelector:(SEL)selector
{
    Class cls = [self class];
    JSValue *function = nil;
    while (!function && cls) {
        function = _classAssociatedJSFunctions[cls][selector].second;
        cls = [cls superclass];
    }
    return function;
}

@end
