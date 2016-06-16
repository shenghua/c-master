//
//  SessionChatMessage.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/10.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _SessionChatMessagePriority {
    SessionChatMessagePriority_High,
    SessionChatMessagePriority_Normal,
} SessionChatMessagePriority;

@interface SessionChatMessage : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) SessionChatMessagePriority priority;
- (instancetype)initWithUserName:(NSString *)userName time:(NSString *)time message:(NSString *)message priority:(SessionChatMessagePriority)priority;
@end
