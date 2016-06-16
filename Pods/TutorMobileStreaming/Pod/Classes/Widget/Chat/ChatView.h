//
//  ChatView.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/24.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatView : UIView <UITableViewDataSource, UITableViewDelegate>
- (void)addChats:(NSArray *)chats;
- (void)removeAllChats;
@end
