//
//  JSValue+FIXIT.h
//  FIXIT
//
//  Created by ricky on 2018/12/9.
//

#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSValue (FIXiT)
@property (nonatomic, readonly) BOOL fixit_isNil;
@end

NS_ASSUME_NONNULL_END
