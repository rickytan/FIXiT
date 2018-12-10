//
//  NSObject+FIXIT.h
//  FIXIT
//
//  Created by ricky on 2018/12/10.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (FIXiT)

- (void)fixit_setJSFunction:(JSValue *)function forSelector:(SEL)selector isClassMethod:(BOOL)classMethod;

- (JSValue *)fixit_JSFunctionForSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
