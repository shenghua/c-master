//
//  TMNAppInfoUtil.h
//  TutorMobile
//
//  Created by Dean Chen_陳俊昌 on 2015/10/16.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNConstants.h"

@interface TMNAppInfoUtil : NSObject

/**
 *  取得app版本號碼
 *
 *  @return <#return value description#>
 */
+ (NSString *)appVersionString;

/**
 *  取得build版本號碼
 *
 *  @return <#return value description#>
 */
+ (NSString *)buildVersionString;

/**
 *  取得用:組合app版本與build版本的字串
 *
 *  @return <#return value description#>
 */
+ (NSString *)appVersionBuildString;

/**
 *  取得app用的brandID
 *
 *  @return <#return value description#>
 */
+ (TMNBrandID)brandIDForApp;

/**
 *  組出系統與OS版本號
 *
 *  @param systemVersion <#systemVersion description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)platformVersionFromSystemVersion:(NSString *)systemVersion;

@end
