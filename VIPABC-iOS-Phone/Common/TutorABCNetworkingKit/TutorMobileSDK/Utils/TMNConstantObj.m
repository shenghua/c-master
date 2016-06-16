//
//  TMNConstantObj.m
//  TutorMobile
//
//  Created by Dean Chen_陳俊昌 on 2015/11/11.
//  Copyright © 2015年 TutorABC. All rights reserved.
//

#import "TMNConstantObj.h"

@interface TMNConstantObj()

// 提醒推播通知對應
@property (strong, nonatomic) NSDictionary *reminderTypeDict;

@end

@implementation TMNConstantObj

/**
 *  取得singleton實體
 *
 *  @return <#return value description#>
 */
+ (id)sharedInstance {
    static TMNConstantObj *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        
        self.reminderTypeDict = kPushChannelKey;
        
    }
    return self;
}

/**
 *  所有後台推播channel key值
 *
 *  @return <#return value description#>
 */
- (NSString *)allReminderKeys {
    NSString *allChannelKeys = @"";
    
    for (NSString *channelKey in self.reminderTypeDict.allValues) {
        allChannelKeys = [allChannelKeys stringByAppendingString:channelKey];
        allChannelKeys = [allChannelKeys stringByAppendingString:@", "];
    }
    allChannelKeys = [allChannelKeys substringToIndex:allChannelKeys.length - 2];
    
    return allChannelKeys;
}

/**
 *  取得對應reminder type的後台channel key
 *
 *  @param reminderType <#reminderType description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)channelKeyForReminderType:(TMNReminderType)reminderType {
    return [self.reminderTypeDict objectForKey:@(reminderType)];
}

@end
