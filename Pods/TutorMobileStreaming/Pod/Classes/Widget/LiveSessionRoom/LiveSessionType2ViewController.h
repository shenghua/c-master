//
//  LiveSessionType2ViewController.h
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/10/27.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const _Nonnull UILiveSessionType2WillCloseNotification;

@interface LiveSessionType2ViewController : UIViewController
@property (nonnull, nonatomic, strong) NSDictionary *classInfo;

@property (nullable, nonatomic, copy) void (^closeButtonAction) (void);
@end
