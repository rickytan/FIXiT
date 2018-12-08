//
//  FIXIT.m
//  FIXIT
//
//  Created by ricky on 2018/12/8.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "FIXIT.h"
#import "NSInvocation+FIXIT.h"

@protocol Fixit <JSExport>
+ (instancetype)fix:(NSString *)clsName;
- (instancetype)initWithClsName:(NSString *)clsName;
JSExportAs(instanceMethod, - (NSString *)fixInstanceMethod:(NSString *)selName usingBlock:(JSValue *)block);
JSExportAs(classMethod, - (NSString *)fixClassMethod:(NSString *)selName usingBlock:(JSValue *)block);

@end

@interface Fixit : NSObject <Fixit>
@property (nonatomic, unsafe_unretained) Class cls;
@end

@interface NSObject (FIXIT)
@property (atomic, strong, readonly) NSMutableDictionary <NSString *, JSValue *> * fixit_associatedJSValue;

- (JSValue *)associatedJSValueForSelector:(SEL)selector;
- (void)setAssociatedJSValue:(JSValue *)value forSelector:(SEL)selector;
@end

@implementation NSObject (FIXIT)

- (NSMutableDictionary<NSString *, JSValue *> *)fixit_associatedJSValue
{
    @synchronized (self) {
        NSMutableDictionary<NSString *, JSValue *> * dict = objc_getAssociatedObject(self, @selector(fixit_associatedJSValue));
        if (!dict) {
            dict = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self, @selector(fixit_associatedJSValue), dict, OBJC_ASSOCIATION_RETAIN);
        }
        return dict;
    }
    return nil;
}

- (JSValue *)associatedJSValueForSelector:(SEL)selector
{
    return self.fixit_associatedJSValue[NSStringFromSelector(selector)];
}

- (void)setAssociatedJSValue:(JSValue *)value forSelector:(SEL)selector
{
    self.fixit_associatedJSValue[NSStringFromSelector(selector)] = value;
}

@end

static void __FIXIT_FORWARDING__(__unsafe_unretained id self, SEL _cmd, NSInvocation *invocation) {
    NSParameterAssert(self);
    NSParameterAssert(invocation);

    JSValue *function = [(id)[self class] associatedJSValueForSelector:invocation.selector];
    JSValue *returnVal = [[function invokeMethod:@"bind" withArguments:@[self]] callWithArguments:invocation.fixit_arguments];
    [invocation setFixit_returnValue:returnVal];
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
    }
    return self;
}

- (NSString *)fixInstanceMethod:(NSString *)selName usingBlock:(JSValue *)block
{
    Class cls = self.cls;
    SEL sel = NSSelectorFromString(selName);
    Method met = class_getInstanceMethod(cls, sel);
    IMP imp = [cls instanceMethodForSelector:sel];

    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"__fixit_%@_%p", selName, block]);
    IMP forwardIMP = _objc_msgForward;
#ifndef __arm64__
    NSMethodSignature *sig = [cls instanceMethodSignatureForSelector:sel];
    if ([sig.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
        forwardIMP = _objc_msgForward_stret;
    }
#endif

    if (![cls instancesRespondToSelector:newSel]) {
        if (class_addMethod(cls, newSel, forwardIMP, method_getTypeEncoding(met))) {
            method_exchangeImplementations(met, class_getInstanceMethod(cls, newSel));
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

    [cls setAssociatedJSValue:block forSelector:sel];

    return [NSString stringWithFormat:@"%p", imp];
}

- (NSString *)fixClassMethod:(NSString *)selName usingBlock:(JSValue *)block
{
    return nil;
}

@end

@interface FIXIT ()
@property (nonatomic, strong) JSContext *context;
@end

@implementation FIXIT

+ (instancetype)fix
{
    static dispatch_once_t onceToken;
    static FIXIT * _instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [FIXIT new];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        JSVirtualMachine *machine = [[JSVirtualMachine alloc] init];
        JSContext * context = [[JSContext alloc] initWithVirtualMachine:machine];
        context.name = @"FIXIT";
        context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"%@: %@", context, exception);
        };

        context[@"Fixit"] = [Fixit class];

        context[@"_instanceCallMethod"] = ^(JSValue *instance, NSString *selName, JSValue *arguments) {
            id obj = [instance toObject];
            SEL sel = NSSelectorFromString(selName);

            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:sel]];
            invocation.selector = sel;
            invocation.fixit_arguments = [arguments toArray];
            [invocation invokeWithTarget:obj];
            return [invocation fixit_returnValueInContext:[FIXIT fix].context];
        };

        context[@"dispatch_after"] = ^(double time, JSValue *func) {
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

        context[@"_OC_log"] = ^() {
            NSArray *args = [JSContext currentArguments];
            for (JSValue *val in args) {
                NSLog(@"[FIXIT]: %@", val);
            }
        };

        _context = context;

        NSString *jsPath = [[NSBundle bundleForClass:self.class] pathForResource:@"fixit" ofType:@"js"];
        NSError *error = nil;
        NSString *script = [NSString stringWithContentsOfFile:jsPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
        NSAssert(error == nil, @"can't load fixit.js");
        [_context evaluateScript:script withSourceURL:[NSURL fileURLWithPath:jsPath]];
    }
    return self;
}

- (NSString *)_compile:(NSString *)source
{
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"(?<!\\\\)\\.\\s*(\\w+)\\s*\\("
                                                          options:0
                                                            error:NULL];
    });

    return [regex stringByReplacingMatchesInString:source
                                           options:0
                                             range:NSMakeRange(0, source.length)
                                      withTemplate:@"._c(\"$1\")("];
}

- (void)executeScript:(NSString *)script
{
    NSString *jsCode = [NSString stringWithFormat:@"!function() {\ntry {\n%@\n} catch (e) {\n    console.log(e);\n}\n}();", [self _compile:script]];
    [_context evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"main.js"]];
}

@end
