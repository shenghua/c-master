//
//  LiveSessionRoomViewController.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/6/23.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveSession.h"
#import "ChatView.h"

@interface LiveSessionRoomViewController : UIViewController <LiveSessionDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSDictionary *classInfo;
@end
