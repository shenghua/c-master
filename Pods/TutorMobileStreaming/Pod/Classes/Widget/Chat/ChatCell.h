//
//  ChatCell.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/24.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionChatMessage.h"

@interface ChatCell : UITableViewCell
@property (strong, nonatomic) UILabel *userTimeLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (assign, nonatomic) SessionChatMessagePriority priority;
@end
