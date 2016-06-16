//
//  SessionChatMessage.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/10.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "SessionChatMessage.h"

@implementation SessionChatMessage
- (instancetype)initWithUserName:(NSString *)userName time:(NSString *)time message:(NSString *)message priority:(SessionChatMessagePriority)priority {
    if (self = [super init]) {
        _userName = [userName copy];
        _time = [time copy];
        _message = [message copy];
        _priority = priority;
    }
    return self;
}
@end
