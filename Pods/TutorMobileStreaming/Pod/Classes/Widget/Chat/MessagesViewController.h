//
//  MessagesViewController.h
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/9/3.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "LiveSession.h"
#import <JSQMessagesViewController/JSQMessagesViewController.h>

extern NSString const *kSessionRoleTypeStudent;
extern NSString const *kSessionRoleTypeCohost;
extern NSString const *kSessionRoleTypeCoordinator;
extern NSString const *kSessionRoleTypeSales;

@interface MessagesViewController : JSQMessagesViewController

@property (nonatomic, weak) LiveSession *session;
@property (nonatomic, weak) NSMutableArray *messages;
@property (nonatomic, strong) NSString *consultantName;
@end
