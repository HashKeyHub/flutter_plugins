//
//  Biology.h
//  local_auth
//
//  Created by 李广斌 on 2020/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Biology : NSObject

+(void) biologyUnLockTips:(NSString *)tips negativeBtn:(NSString *)negativeBtn positiveBtn:(NSString *)positiveBtn sensitiveTransaction:(NSInteger)sensitiveTransaction unLockSuccess:(void (^)(void)) unLockSuccess unLockFail:(void (^)(NSInteger)) unLockFail unLockError:(void (^)(NSInteger)) unLockError;

+(NSInteger)isSupport;
+(NSInteger)getWhitchBiology;
+(void) setBiologyOkTitle1:(NSString *)title1 negativeBtn:(NSString *)negativeBtn positiveBtn:(NSString *)positiveBtn onNegative:(void (^)(void))onNegative onPositive:(void (^)(void))onPositive;
+(void) setBiologyshouldOpenTitle2:(NSString *)title2 negativeBtn:(NSString *)negativeBtn onNegative:(void (^)(void))onNegative;

+(void) biologyOutTitle3:(NSString *)title3 negativeBtn:(NSString *)negativeBtn positiveBtn:(NSString *)positiveBtn onNegative:(void (^)(void))onNegative onPositive:(void (^)(void))onPositive;
@end

NS_ASSUME_NONNULL_END
