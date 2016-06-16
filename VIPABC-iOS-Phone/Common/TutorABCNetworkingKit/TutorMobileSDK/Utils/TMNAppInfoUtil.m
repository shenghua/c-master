//
//  TMNAppInfoUtil.m
//  TutorMobile
//
//  Created by Dean Chen_陳俊昌 on 2015/10/16.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "TMNAppInfoUtil.h"

@implementation TMNAppInfoUtil

/**
 *  取得app版本號碼
 *
 *  @return <#return value description#>
 */
+ (NSString *)appVersionString {
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

/**
 *  取得build版本號碼
 *
 *  @return <#return value description#>
 */
+ (NSString *)buildVersionString {
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
}

/**
 *  取得用:組合app版本與build版本的字串
 *
 *  @return <#return value description#>
 */
+ (NSString *)appVersionBuildString {
#ifdef HOST_STAGE
    return [NSString stringWithFormat:@"%@:%@@stage", [TMNAppInfoUtil appVersionString], [TMNAppInfoUtil buildVersionString]];
#else
    return [NSString stringWithFormat:@"%@:%@", [TMNAppInfoUtil appVersionString], [TMNAppInfoUtil buildVersionString]];
#endif
}

/**
 *  取得app用的brandID
 *
 *  @return <#return value description#>
 */
+ (TMNBrandID)brandIDForApp {
    return TMNBrandID_TutorABC;
}

/**
 *  組出系統與OS版本號
 *
 *  @param systemVersion <#systemVersion description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)platformVersionFromSystemVersion:(NSString *)systemVersion {
    return [NSString stringWithFormat:@"iOS %@", systemVersion];
}

@end
