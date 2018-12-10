//
//  FIXIT.h
//  FIXIT
//
//  Created by ricky on 2018/12/8.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface FIXiT : NSObject
+ (instancetype)fix;
+ (JSContext *)context;
- (void)executeScript:(NSString *)script;
@end

NS_ASSUME_NONNULL_END
