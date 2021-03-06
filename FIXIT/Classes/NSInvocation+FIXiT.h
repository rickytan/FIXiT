//
//  NSInvocation+FIXIT.h
//  FIXIT
//
//  Created by ricky on 2018/12/8.
//

#import <Foundation/Foundation.h>

@class JSValue, JSContext;

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (FIXIT)
@property (nonatomic, strong) NSArray *fixit_arguments;
- (JSValue *)fixit_returnValueInContext:(JSContext *)context;
- (void)fixit_setReturnValue:(JSValue *)value;
- (void)fixit_setArgument:(id)value atIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
