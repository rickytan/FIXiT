//
//  FIXIT.m
//  FIXIT
//
//  Created by ricky on 2018/12/8.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>

#import "FIXIT.h"

@protocol Fixit <JSExport>
+ (instancetype)fix:(NSString *)clsName;
- (instancetype)initWithClsName:(NSString *)clsName;
JSExportAs(instanceMethod, - (NSString *)fixInstanceMethod:(NSString *)selName usingBlock:(JSValue *)block);
JSExportAs(classMethod, - (NSString *)fixClassMethod:(NSString *)selName usingBlock:(JSValue *)block);

@end

@interface Fixit : NSObject <Fixit>
@property (nonatomic, unsafe_unretained) Class cls;
@end

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
    NSMethodSignature *sig = [cls instanceMethodSignatureForSelector:sel];
    IMP imp = [cls instanceMethodForSelector:sel];

    SEL newSel = sel_registerName([NSString stringWithFormat:@"__fixit_%@_%p", selName, block].UTF8String);
    IMP newImp = imp_implementationWithBlock(^(id self, ...) {
        va_list args;
        va_start(args, self);

        NSUInteger numberOfArgs = sig.numberOfArguments;

        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:numberOfArgs - 1];
        [arguments addObject:self];

        for (NSUInteger i = 2; i < numberOfArgs; ++i) {
            const char * type = [sig getArgumentTypeAtIndex:i];
            switch (type[0]) {
                case 'c':
                case 'i':
                case 's':
                case 'l':
                {
                    int32_t value = va_arg(args, int32_t);
                    [arguments addObject:@(value)];
                }
                    break;
                case 'B':
                case 'C':
                case 'I':
                case 'S':
                case 'L':
                {
                    uint32_t value = va_arg(args, uint32_t);
                    [arguments addObject:@(value)];
                }
                    break;
                case 'f':case 'd':
                {
                    double value = va_arg(args, double);
                    [arguments addObject:@(value)];
                }
                    break;
                case 'q':
                {
                    long long value = va_arg(args, long long);
                    [arguments addObject:@(value)];
                }
                    break;
                case 'Q':
                {
                    unsigned long long value = va_arg(args, unsigned long long);
                    [arguments addObject:@(value)];
                }
                    break;
                case '*':
                {
                    char * value = va_arg(args, char *);
                    if (value) {
                        [arguments addObject:[JSValue valueWithObject:[[NSString alloc] initWithUTF8String:value] inContext:[JSContext currentContext]]];
                    }
                    else {
                        [arguments addObject:[NSNull null]];
                    }
                }
                    break;
                case '@':case '#':
                {
                    id value = va_arg(args, id);
                    if (value) {
                        [arguments addObject:value];
                    }
                    else {
                        [arguments addObject:[NSNull null]];
                    }
                }
                    break;
                case '{':
                {
                    if (strcmp(type, @encode(CGPoint)) == 0) {
                        CGPoint value = va_arg(args, CGPoint);
                        [arguments addObject:[JSValue valueWithPoint:value inContext:[JSContext currentContext]]];
                    } else if (strcmp(type, @encode(CGSize))) {
                        CGSize value = va_arg(args, CGSize);
                        [arguments addObject:[JSValue valueWithSize:value inContext:[JSContext currentContext]]];
                    } else if (strcmp(type, @encode(CGRect))) {
                        CGRect value = va_arg(args, CGRect);
                        [arguments addObject:[JSValue valueWithRect:value inContext:[JSContext currentContext]]];
                    } else if (strcmp(type, @encode(NSRange))) {
                        NSRange value = va_arg(args, NSRange);
                        [arguments addObject:[JSValue valueWithRange:value inContext:[JSContext currentContext]]];
                    } else {
                        [arguments addObject:[JSValue valueWithUndefinedInContext:[JSContext currentContext]]];
                    }
                    break;
                }
                default:
                    [arguments addObject:[JSValue valueWithUndefinedInContext:[JSContext currentContext]]];
                    break;
            }
        }
        va_end(args);

        return [block callWithArguments:arguments];
    });
    if (class_addMethod(cls, newSel, newImp, method_getTypeEncoding(met))) {
        method_exchangeImplementations(met, class_getInstanceMethod(cls, newSel));
    }
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

        context[@"_fixit_im"] = ^(NSString *clsName, NSString *selName, JSValue *function) {
            Class cls = NSClassFromString(clsName);
            SEL sel = NSSelectorFromString(selName);
            Method met = class_getInstanceMethod(cls, sel);
            const char *typeEncoding = method_getTypeEncoding(met);
            IMP imp = [cls instanceMethodForSelector:sel];

            SEL newSel = sel_registerName([NSString stringWithFormat:@"__fixit_%@_%p", selName, function].UTF8String);
            IMP newImp = imp_implementationWithBlock(^(id self, ...) {
                va_list args;
                va_start(args, self);
                NSUInteger size, align;
                NSGetSizeAndAlignment(typeEncoding, &size, &align);
                return [function callWithArguments:[JSContext currentArguments]];
            });
            if (class_addMethod(cls, newSel, newImp, method_getTypeEncoding(met))) {
                method_exchangeImplementations(met, class_getInstanceMethod(cls, newSel));
            }
            return [NSString stringWithFormat:@"%p", imp];
        };
        context[@"__fixit_cm"] = ^(NSString *clsName, NSString *selName, JSValue *function) {

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
