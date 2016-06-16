//
//  VASessionRoomViewController.h
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/15.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VABaseViewController.h"

extern NSString *const _Nonnull VASessionRoomWillCloseNotification;

@interface VASessionRoomViewController : VABaseViewController

@property (nonnull, nonatomic, strong) NSDictionary * classInfo;

- (nullable instancetype)initWithClassInfo:(nonnull NSDictionary *)classInfo
                                    isDemo:(BOOL)isDemo;

@end
