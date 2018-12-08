//
//  FIXIT.h
//  FIXIT
//
//  Created by ricky on 2018/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FIXIT : NSObject
+ (instancetype)fix;

- (void)executeScript:(NSString *)script;
@end

NS_ASSUME_NONNULL_END
