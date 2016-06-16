//
//  VASessionRoom1ViewController.h
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/19.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VABaseViewController.h"

@interface VASessionRoom1ViewController : VABaseViewController

@property (nonnull, nonatomic, strong) NSDictionary * classInfo;

- (nullable instancetype)initWithClassInfo:(nonnull NSDictionary *)classInfo
                                    isDemo:(BOOL)isDemo;

@end
