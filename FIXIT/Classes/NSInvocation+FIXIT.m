//
//  NSInvocation+FIXIT.m
//  FIXIT
//
//  Created by ricky on 2018/12/8.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import <JavaScriptCore/JavaScriptCore.h>

#import "NSInvocation+FIXIT.h"

@implementation NSInvocation (FIXIT)

// Thanks to the ReactiveCocoa team for providing a generic solution for this.
- (id)fixit_argumentAtIndex:(NSUInteger)index {
    const char *argType = [self.methodSignature getArgumentTypeAtIndex:index];
    // Skip const type qualifier.
    if (argType[0] == _C_CONST) argType++;

#define WRAP_AND_RETURN(type) do { type val = 0; [self getArgument:&val atIndex:(NSInteger)index]; return @(val); } while (0)
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing id returnObj;
        [self getArgument:&returnObj atIndex:(NSInteger)index];
        return returnObj;
    } else if (strcmp(argType, @encode(SEL)) == 0) {
        SEL selector = 0;
        [self getArgument:&selector atIndex:(NSInteger)index];
        return NSStringFromSelector(selector);
    } else if (strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing Class theClass = Nil;
        [self getArgument:&theClass atIndex:(NSInteger)index];
        return theClass;
        // Using this list will box the number with the appropriate constructor, instead of the generic NSValue.
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(argType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(bool)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        [self getArgument:&block atIndex:(NSInteger)index];
        return [block copy];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);

        unsigned char valueBytes[valueSize];
        [self getArgument:valueBytes atIndex:(NSInteger)index];

        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
    return nil;
#undef WRAP_AND_RETURN
}

- (NSArray *)fixit_arguments {
    NSMutableArray *argumentsArray = [NSMutableArray array];
    for (NSUInteger idx = 2; idx < self.methodSignature.numberOfArguments; idx++) {
        [argumentsArray addObject:[self fixit_argumentAtIndex:idx] ?: NSNull.null];
    }
    return [argumentsArray copy];
}

- (void)setFixit_arguments:(NSArray *)fixit_arguments
{
    [fixit_arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        idx = idx + 2;
        const char *argType = [self.methodSignature getArgumentTypeAtIndex:idx];
        // Skip const type qualifier.
        if (argType[0] == _C_CONST) argType++;
#define READ_ANS_SET(type, method) do { type val = [obj method]; [self setArgument:&val atIndex:(NSInteger)index]; } while (0)
        if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
            __autoreleasing id returnObj;
            [self setArgument:&returnObj atIndex:(NSInteger)index];
        } else if (strcmp(argType, @encode(SEL)) == 0) {
            SEL selector = 0;
            [self setArgument:&selector atIndex:(NSInteger)index];
        } else if (strcmp(argType, @encode(Class)) == 0) {
            __autoreleasing Class theClass = Nil;
            [self setArgument:&theClass atIndex:(NSInteger)index];
            // Using this list will box the number with the appropriate constructor, instead of the generic NSValue.
        } else if (strcmp(argType, @encode(char)) == 0) {
            READ_ANS_SET(char, charValue);
        } else if (strcmp(argType, @encode(int)) == 0) {
            READ_ANS_SET(int, intValue);
        } else if (strcmp(argType, @encode(short)) == 0) {
            READ_ANS_SET(short, shortValue);
        } else if (strcmp(argType, @encode(long)) == 0) {
            READ_ANS_SET(long, longValue);
        } else if (strcmp(argType, @encode(long long)) == 0) {
            READ_ANS_SET(long long, longLongValue);
        } else if (strcmp(argType, @encode(unsigned char)) == 0) {
            READ_ANS_SET(unsigned char, unsignedCharValue);
        } else if (strcmp(argType, @encode(unsigned int)) == 0) {
            READ_ANS_SET(unsigned int, unsignedIntValue);
        } else if (strcmp(argType, @encode(unsigned short)) == 0) {
            READ_ANS_SET(unsigned short, unsignedShortValue);
        } else if (strcmp(argType, @encode(unsigned long)) == 0) {
            READ_ANS_SET(unsigned long, unsignedLongValue);
        } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
            READ_ANS_SET(unsigned long long, unsignedLongLongValue);
        } else if (strcmp(argType, @encode(float)) == 0) {
            READ_ANS_SET(float, floatValue);
        } else if (strcmp(argType, @encode(double)) == 0) {
            READ_ANS_SET(double, doubleValue);
        } else if (strcmp(argType, @encode(BOOL)) == 0) {
            READ_ANS_SET(BOOL, boolValue);
        } else if (strcmp(argType, @encode(bool)) == 0) {
            READ_ANS_SET(BOOL, boolValue);
        } else if (strcmp(argType, @encode(char *)) == 0) {
            READ_ANS_SET(const char *, pointerValue);
        } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
            __unsafe_unretained id block = nil;
            [self setArgument:&block atIndex:(NSInteger)index];
        } else {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(argType, &valueSize, NULL);

            unsigned char valueBytes[valueSize];
            [self setArgument:valueBytes atIndex:(NSInteger)index];
        }
#undef READ_ANS_SET
    }];
}

- (JSValue *)fixit_returnValueInContext:(JSContext *)context
{
    const char *argType = self.methodSignature.methodReturnType;
    // Skip const type qualifier.
    if (argType[0] == _C_CONST) argType++;

#define WRAP_AND_RETURN(type, method) do { type val = 0; [self getReturnValue:&val]; return [JSValue valueWith##method:val inContext:context]; } while (0)
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing id returnObj;
        [self getReturnValue:&returnObj];
        return [JSValue valueWithObject:returnObj inContext:context];
    } else if (strcmp(argType, @encode(SEL)) == 0) {
        SEL selector = 0;
        [self getReturnValue:&selector];
        return [JSValue valueWithObject:NSStringFromSelector(selector) inContext:context];
    } else if (strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing Class theClass = Nil;
        [self getReturnValue:&theClass];
        return [JSValue valueWithObject:theClass inContext:context];
        // Using this list will box the number with the appropriate constructor, instead of the generic NSValue.
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char, Int32);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int, Int32);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short, Int32);
    } else if (strcmp(argType, @encode(long)) == 0) {
#if __arm64
        WRAP_AND_RETURN(long, Double);
#else
        WRAP_AND_RETURN(long, Int32);
#endif
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long, Double);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char, UInt32);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int, UInt32);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short, UInt32);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
#if __arm64
        WRAP_AND_RETURN(unsigned long, Double);
#else
        WRAP_AND_RETURN(unsigned long, UInt32);
#endif
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long, Double);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float, Double);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double, Double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL, Bool);
    } else if (strcmp(argType, @encode(bool)) == 0) {
        WRAP_AND_RETURN(BOOL, Bool);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        const char *val = NULL;
        [self getReturnValue:&val];
        return [JSValue valueWithObject:[NSValue valueWithPointer:val] inContext:context];
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        [self getArgument:&block atIndex:(NSInteger)index];
        return [JSValue valueWithObject:[block copy] inContext:context];
    } else if (strcmp(argType, @encode(CGPoint)) == 0) {
        CGPoint val = {0};
        [self getReturnValue:&val];
        return [JSValue valueWithPoint:val inContext:context];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);

        unsigned char valueBytes[valueSize];
        [self getReturnValue:valueBytes];

        return [JSValue valueWithObject:[NSValue valueWithBytes:valueBytes objCType:argType] inContext:context];
    }
    return [JSValue valueWithUndefinedInContext:context];
#undef WRAP_AND_RETURN
}

@end
