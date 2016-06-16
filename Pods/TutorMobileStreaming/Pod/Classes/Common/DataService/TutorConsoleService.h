//
//  TutorConsoleService.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/2.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RtmpService.h"

typedef enum _HelpMsgStatus {
    HelpMsgStatus_Waiting           = 1,
    HelpMsgStatus_Processing        = 2,
    HelpMsgStatus_Done              = 3,
    HelpMsgStatus_Closed            = 4,
    HelpMsgStatus_RequireResponse   = 5,
} HelpMsgStatus;

typedef enum _HelpMsgType {
    HelpMsgType_System          = 1,
    HelpMsgType_User            = 2,
    HelpMsgType_Consultant      = 4,
    HelpMsgType_Alert           = 5,
    HelpMsgType_Clicked         = 6,
    HelpMsgType_NotSatisfied    = 7,
    HelpMsgType_Material        = 8,
} HelpMsgType;

typedef enum _HelpMsgConfirmed {
    HelpMsgConfirmed_Yes,
    HelpMsgConfirmed_Accept,
    HelpMsgConfirmed_No,
} HelpMsgConfirmed;

@protocol TutorConsoleServiceDelegate <NSObject>
- (void)onHelpMessage:(NSString *)messageId msgIdx:(int)msgIdx status:(HelpMsgStatus)status;
@end

@interface TutorConsoleService : RtmpService
- (id)initWithUrl:(NSString *)url delegate:(id<TutorConsoleServiceDelegate>)delegate userParams:(NSDictionary *)userParams;
- (void)sendHelpMessage:(NSString *)message
        custSupMsgIndex:(int)custSupMsgIndex
            custSupType:(int)custSupType;
- (void)confirmHelpMsg:(NSString *)msgId confirmed:(HelpMsgConfirmed)confirmed;
@end
