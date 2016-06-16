//
//  TMNConstantObj.h
//  TutorMobile
//
//  Created by Dean Chen_陳俊昌 on 2015/11/11.
//  Copyright © 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNConstants.h"

/**
 *  singleton常數物件
 */
@interface TMNConstantObj : NSObject

/**
 *  取得singleton實體
 *
 *  @return <#return value description#>
 */
+ (id)sharedInstance;

/**
 *  所有後台推播channel key值
 *
 *  @return <#return value description#>
 */
- (NSString *)allReminderKeys;

/**
 *  取得對應reminder type的後台channel key
 *
 *  @param reminderType <#reminderType description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)channelKeyForReminderType:(TMNReminderType)reminderType;

@end
