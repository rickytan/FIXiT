//
//  FIXIT.m
//  FIXIT
//
//  Created by ricky on 2018/12/8.
//

#import <objc/message.h>

#import "FIXiT.h"
#import "NSInvocation+FIXiT.h"
#import "NSObject+FIXiT.h"

#define FIXIT_LOG(format, ...)      NSLog(@"[FIXiT]: " format, __VA_ARGS__)

@protocol Fixit <JSExport>
+ (instancetype)fix:(NSString *)clsName;
- (instancetype)initWithClsName:(NSString *)clsName;
JSExportAs(instanceMethod, - (JSValue *)fixInstanceMethod:(NSString *)selName usingBlock:(JSValue *)block);
JSExportAs(classMethod, - (JSValue *)fixClassMethod:(NSString *)selName usingBlock:(JSValue *)block);

@end

@interface Fixit : NSObject <Fixit>
@property (nonatomic, unsafe_unretained) Class cls;
@end

static id wrapObjCWithProxiedObject(id object) {
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[object count]];
        [object enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [arr addObject:wrapObjCWithProxiedObject(obj)];
        }];
        return [arr copy];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[object count]];
        [object enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            dic[key] = wrapObjCWithProxiedObject(obj);
        }];
        return [dic copy];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return object;
    } else if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if ([object isKindOfClass:[NSDate class]]) {
        return object;
    } else {
        return [[FIXiT context].globalObject[@"makeProxiedObject"] callWithArguments:@[object ?: [NSNull null]]];
    }
}

static void __FIXIT_FORWARDING__(__unsafe_unretained id self, SEL _cmd, NSInvocation *invocation) {
    NSParameterAssert(self);
    NSParameterAssert(invocation);

    JSValue *function = [self fixit_JSFunctionForSelector:invocation.selector];
    JSValue *proxySelf = [[FIXiT context].globalObject[@"makeProxiedObject"] callWithArguments:@[self]];
    JSValue *returnVal = [[function invokeMethod:@"bind" withArguments:@[proxySelf]] callWithArguments:wrapObjCWithProxiedObject(invocation.fixit_arguments)];
    [invocation fixit_setReturnValue:returnVal];
}

@implementation Fixit

+ (instancetype)fix:(NSString *)clsName
{
    return [[self alloc] initWithClsName:clsName];
}

- (instancetype)initWithClsName:(NSString *)clsName
{
    self = [super init];
    if (self) {
        self.cls = NSClassFromString(clsName);
        if (!self.cls) {
            FIXIT_LOG(@"Class %@ doesn't exists!", clsName);
        }
    }
    return self;
}

- (JSValue *)fixInstanceMethod:(NSString *)selName usingBlock:(JSValue *)block
{
    Class cls = self.cls;
    SEL sel = NSSelectorFromString(selName);
    Method met = class_getInstanceMethod(cls, sel);

    NSString *newSelString = [NSString stringWithFormat:@"__fixit_%@_%@_%p", cls, selName, block];
    SEL newSel = NSSelectorFromString(newSelString);
    IMP forwardIMP = _objc_msgForward;
#ifndef __arm64__
    NSMethodSignature *sig = [cls instanceMethodSignatureForSelector:sel];
    if ([sig.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
        forwardIMP = _objc_msgForward_stret;
    }
#endif

    {
        IMP originIMP = class_replaceMethod(cls, sel, forwardIMP, method_getTypeEncoding(met)) ?: method_getImplementation(met);
        if (originIMP) {
            class_addMethod(cls, newSel, originIMP, method_getTypeEncoding(met));
        } else {
            return [JSValue valueWithObject:^() {} inContext:[JSContext currentContext]];
        }
    }

    if (class_getMethodImplementation(cls, @selector(forwardInvocation:)) != (IMP)__FIXIT_FORWARDING__) {
        Method forward = class_getInstanceMethod(cls, @selector(forwardInvocation:));
        const char *encoding = method_getTypeEncoding(forward);
        IMP invokeIMP = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)__FIXIT_FORWARDING__, encoding);
        if (invokeIMP) {
            class_addMethod(cls, NSSelectorFromString(@"__fixit_forwardInvocation:"), invokeIMP, encoding);
        }
    }

    [cls fixit_setJSFunction:[[FIXiT context].globalObject[@"unproxyFunction"] callWithArguments:@[block]]
                 forSelector:sel
               isClassMethod:NO];

    return [[JSContext currentContext].globalObject[@"makeProxiedFunction"] callWithArguments:@[newSelString]];
}

- (JSValue *)fixClassMethod:(NSString *)selName usingBlock:(JSValue *)block
{
    Class cls = self.cls;
    SEL sel = NSSelectorFromString(selName);
    Method met = class_getClassMethod(cls, sel);

    NSString *newSelString = [NSString stringWithFormat:@"__fixit_%@_%@_%p", cls, selName, block];
    SEL newSel = NSSelectorFromString(newSelString);
    IMP forwardIMP = _objc_msgForward;
#ifndef __arm64__
    NSMethodSignature *sig = [cls methodSignatureForSelector:sel];
    if ([sig.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
        forwardIMP = _objc_msgForward_stret;
    }
#endif

    {
        IMP originIMP = class_replaceMethod(object_getClass(cls), sel, forwardIMP, method_getTypeEncoding(met)) ?: method_getImplementation(met);
        if (originIMP) {
            class_addMethod(object_getClass(cls), newSel, originIMP, method_getTypeEncoding(met));
        } else {
            return [JSValue valueWithObject:^() {} inContext:[JSContext currentContext]];
        }
    }

    if (class_getMethodImplementation(object_getClass(cls), @selector(forwardInvocation:)) != (IMP)__FIXIT_FORWARDING__) {
        Method forward = class_getClassMethod(cls, @selector(forwardInvocation:));
        const char *encoding = method_getTypeEncoding(forward);
        IMP invokeIMP = class_replaceMethod(object_getClass(cls), @selector(forwardInvocation:), (IMP)__FIXIT_FORWARDING__, encoding);
        if (invokeIMP) {
            class_addMethod(object_getClass(cls), NSSelectorFromString(@"__fixit_forwardInvocation:"), invokeIMP, encoding);
        }
    }

    [cls fixit_setJSFunction:[[FIXiT context].globalObject[@"unproxyFunction"] callWithArguments:@[block]]
                 forSelector:sel
               isClassMethod:YES];

    return [[JSContext currentContext].globalObject[@"makeProxiedFunction"] callWithArguments:@[newSelString]];
}

@end

static JSValue * instanceCallMethod(JSValue *instance, NSString *selName, JSValue *arguments) {
    id obj = instance.toObject;
    SEL sel = NSSelectorFromString(selName);

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:sel]];
    invocation.selector = sel;
    NSInteger length = arguments[@"length"].toInt32;
    for (NSInteger i = 0; i < length; ++i) {
        [invocation fixit_setArgument:arguments[i] atIndex:i + 2];
    }
//    invocation.fixit_arguments = [arguments toArray];
    [invocation invokeWithTarget:obj];
    return [invocation fixit_returnValueInContext:[FIXiT context]];
}

@interface FIXiT ()
@property (nonatomic, strong) JSContext *context;
@end

@implementation FIXiT

+ (instancetype)fix
{
    static dispatch_once_t onceToken;
    static FIXiT * _instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [FIXiT new];
    });
    return _instance;
}

+ (JSContext *)context
{
    static dispatch_once_t onceToken;
    static JSContext * _context = nil;
    dispatch_once(&onceToken, ^{
        JSVirtualMachine *machine = [[JSVirtualMachine alloc] init];
        _context = [[JSContext alloc] initWithVirtualMachine:machine];
    });
    return _context;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        JSContext * context = [self.class context];
        context.name = @"FIXiT";
        context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"%@: %@", context, exception);
        };

        context[@"Fixit"] = [Fixit class];

        context[@"_valueForKey"] = ^(JSValue *target, NSString *key) {
            id object = target.isNull ? nil : target.toObject;
            SEL sel = NSSelectorFromString(key);
            if ([object respondsToSelector:sel]) {
                NSMethodSignature *sig = [object methodSignatureForSelector:sel];
                JSContext *ctx = [JSContext currentContext];
                if (sig.numberOfArguments <= 2) {
                    return [ctx.globalObject[@"makeProxiedObject"] callWithArguments:@[instanceCallMethod(target, key, nil) ?: [NSNull null]]];
                } else {
                    return [[ctx.globalObject[@"makeProxiedFunction"] callWithArguments:@[key]] invokeMethod:@"bind" withArguments:@[target]];
                }
            } else {
                id value = [object valueForKey:key];
                return [[JSContext currentContext].globalObject[@"makeProxiedObject"] callWithArguments:@[value ?: [NSNull null]]];
            }
            return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
        };

        context[@"_setValueForKey"] = ^(JSValue *target, NSString *key, JSValue *value) {
            id object = target.toObject;
            if (object != [NSNull null]) {
                [object setValue:value.toObject forKey:key];
            }
        };

        context[@"_instanceCallMethod"] = ^(JSValue *instance, NSString *selName, JSValue *arguments) {
            return instanceCallMethod(instance, selName, arguments);
        };

        context[@"require"] = ^(NSString *imports) {
            NSArray <NSString *> *clsNames = [[imports stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
            [clsNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                JSContext *ctx = [JSContext currentContext];
                Class cls = NSClassFromString(obj);
                if (cls) {
                    ctx[obj] = [ctx[@"makeProxiedObject"] callWithArguments:@[cls]];
                } else {
                    FIXIT_LOG(@"Class %@ doesn't exists!", obj);
                }
            }];
        };

        context[@"dispatch_after"] = ^(NSTimeInterval time, JSValue *func) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [func callWithArguments:nil];
            });
        };

        context[@"dispatch_async_main"] = ^(JSValue *func) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [func callWithArguments:nil];
            });
        };

        context[@"dispatch_sync_main"] = ^(JSValue *func) {
            if ([NSThread currentThread].isMainThread) {
                [func callWithArguments:nil];
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [func callWithArguments:nil];
                });
            }
        };

        context[@"dispatch_async_global_queue"] = ^(JSValue *func) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [func callWithArguments:nil];
            });
        };

        context[@"CGRectMake"] = ^(JSValue *x, JSValue *y, JSValue *width, JSValue *height) {
            return [NSValue valueWithCGRect:CGRectMake(x.toDouble, y.toDouble, width.toDouble, height.toDouble)];
        };

        context[@"CGPointMake"] = ^(JSValue *x, JSValue *y) {
            return [NSValue valueWithCGPoint:CGPointMake(x.toDouble, y.toDouble)];
        };

        context[@"CGSize"] = ^(JSValue *width, JSValue *height) {
            return [NSValue valueWithCGSize:CGSizeMake(width.toDouble, height.toDouble)];
        };

        context[@"NSMakeRange"] = ^(JSValue *location, JSValue *length) {
            return [NSValue valueWithRange:NSMakeRange(location.toUInt32, length.toUInt32)];
        };

        context[@"_log"] = ^() {
            NSArray *args = [JSContext currentArguments];
            for (JSValue *val in args) {
                FIXIT_LOG(@"%@", val);
            }
        };

        _context = context;

        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"FIXiT"
                                                   withExtension:@"bundle"];
        NSAssert(bundleURL != nil, @"can't load FIXiT.bundle");
        NSString *jsPath = [[NSBundle bundleWithURL:bundleURL] pathForResource:@"fixit"
                                                                        ofType:@"js"];
        NSError *error = nil;
        NSString *script = [NSString stringWithContentsOfFile:jsPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
        NSAssert(error == nil, @"can't load fixit.js");
        [_context evaluateScript:script withSourceURL:[NSURL fileURLWithPath:jsPath]];
    }
    return self;
}

- (void)executeScript:(NSString *)script
{
    NSString *jsCode = [NSString stringWithFormat:@"!function() {\ntry {\n%@\n} catch (e) {\n    console.log(e);\n}\n}();", script];
    [_context evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"main.js"]];
}

@end
