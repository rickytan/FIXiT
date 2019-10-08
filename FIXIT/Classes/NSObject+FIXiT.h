//
//  NSObject+FIXIT.h
//  FIXIT
//
//  Created by ricky on 2018/12/10.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT JSValue *fixit_JSFunctionForClassOfSelector(Class cls, SEL selector, BOOL classMethod);

@interface NSObject (FIXiT)

- (void)fixit_setJSFunction:(JSValue *)function forSelector:(SEL)selector isClassMethod:(BOOL)classMethod;

- (JSValue *)fixit_JSFunctionForSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
