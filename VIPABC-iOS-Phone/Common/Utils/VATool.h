//
//  VATool.h
//  VIPABC4Phone
//
//  Created by ledka on 15/11/24.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAUserModel.h"
#import "TMNConstants.h"

@interface VATool : NSObject

+ (VAUserModel *)fetchUserInfo;

+ (UILabel *)getLabelWithTextString:(NSString *)textString
                           fontSize:(float)fontSize
                          textColor:(UIColor *)textColor
                              sapce:(float)space
                               bold:(BOOL)isBold;

// 系统日历添加事件
+ (void)addCalendarEventWithStartTime:(long long)startTime sessionType:(TMNClassSessionType)sessionType;

// 移除日历时间
+ (void)removeCalendar:(long long)startTime;

// 调用电话
+ (void)sendCall:(NSString *)phoneNo withParentView:(UIView *)parentView;

+ (void)setStatusBarWithColor:(UIColor *)color style:(UIStatusBarStyle)statusBarStyle;

// 根据code获取message
+ (NSString *)fetchMessageWithCode:(NSString *)code;

// 微信分享
+ (void)shareToWeiXinWithSence:(int)scene title:(NSString *)title content:(NSString *)content thumbImage:(UIImage *)thumbImage url:(NSString *)urlString shareImage:(UIImage *)shareImage;

// 是否有麦克风的访问权限
+ (BOOL)hasMicrophonePermission;

// 获取日常用语
+ (NSString *)fetchDailyWord;

// 获取日常用语作者
+ (NSString *)fetchDailyWordAuthor;

// 获取日常图片
+ (UIImage *)fetchDailyImage;

// 是否允许注册
+ (BOOL)isRegisterOpen;

// 是否开启上课日历提醒
+ (BOOL)needCalendarNotification;

// 获取客服电话
+ (NSString *)fetchServiceTelphone;
@end
