//
//  AppDelegate.h
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/13.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)navigateToTabBarPage;

- (void)navigateToEvaluatePage:(NSString *)sessionSn;

- (void)navigateToLaunch2Page;

@end

