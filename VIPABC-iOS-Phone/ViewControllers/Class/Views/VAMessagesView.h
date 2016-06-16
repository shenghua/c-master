//
//  VAMessagesView.h
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/20.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveSession.h"
#import "JSQMessage.h"

@interface VAMessagesView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) LiveSession *session;
@property (nonatomic, strong) UITableView *messagesTableView;
@property (nonatomic, assign) ChatMessageType chatMessageType;
@property (nonatomic, copy) NSString *consultantName;

- (instancetype)initWithMessageType:(ChatMessageType)chatMessageType;

- (void)refreshTableView;

- (void)receiveMessage:(JSQMessage *)chatMessage;

@end
