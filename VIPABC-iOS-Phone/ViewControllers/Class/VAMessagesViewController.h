//
//  VAMessagesViewController.h
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/20.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "LiveSession.h"

@interface VAMessagesViewController : JSQMessagesViewController

@property (nonatomic, weak) LiveSession *session;
@property (nonatomic, weak) NSMutableArray *messages;
@property (nonatomic, strong) NSString *consultantName;

@end
