//
//  LiveSessionType1ViewController.h
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/8/31.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const _Nonnull UILiveSessionType1WillCloseNotification;

@interface LiveSessionType1ViewController : UIViewController
@property (nonnull, nonatomic, strong) NSDictionary * classInfo;

- (nullable instancetype)initWithClassInfo:(nonnull NSDictionary *)classInfo
                                    isDemo:(BOOL)isDemo;
@end
