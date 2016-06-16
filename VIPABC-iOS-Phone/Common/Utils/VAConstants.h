//
//  VAConstants.h
//  VIPABC4Phone
//
//  Created by ledka on 15/11/26.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#ifndef VAConstants_h
#define VAConstants_h

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

typedef void(^VARequestSuccessBlock) (id responseObject);
typedef void(^VARequestFailedBlock) (NSError *error, id responseObject);

//#define RGBCOLOR(r,g,b,a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];

#define iPhone4 [UIScreen mainScreen].bounds.size.height == 480.0
#define iPhone5 [UIScreen mainScreen].bounds.size.height == 568.0
#define iPhone6 [UIScreen mainScreen].bounds.size.height > 568.0

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

// Notification info start
#define VANotificationScrollPageValueChanged @"VANotificationScrollPageValueChanged"
// Notification info end

#define kCurrentUserKey @"currentUser"

#define kHasTappedWaitButton @"kHasTappedWaitButton"
#define kShowClassPreparationPage @"kShowClassPreparationPage"
#define kOpenedFirstTime @"kOpenedFirstTime"

#define kMessageViewRemoveNotification @"kMessageViewRemoveNotification"

#define kCommonMessagesKey @"kCommonMessagesKey"
#define kConfigureInfo @"kConfigureInfo"
#define kDailyImageName @"dailyImageName.png"
#define kDailyWord @"kDailyWord"
#define kDailyWordAuthor @"kDailyWordAuthor"
#define kH5ServerURL @"kH5ServerURL"
#define kApiServerURL @"kApiServerURL"
#define kCalendarNotification @"kCalendarNotification"
#define kServiceTelphone @"kServiceTelphone"

#define kUserDefaults [NSUserDefaults standardUserDefaults]

typedef enum {
    
    MessageTypeMe = 0, // 自己发的消息
    MessageTypeOther = 1 //别人发的消息
    
} MessageType;

typedef enum {
    
    ChatMessageTypeIT = 0, // IT聊天界面
    ChatMessageTypeOther = 1 //一般聊天界面
    
} ChatMessageType;

#endif
