//
//  VATool.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/24.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VATool.h"
#import <EventKit/EventKit.h>
#import "AppDelegate.h"
#import "WXApi.h"
#import <AVFoundation/AVFoundation.h>

@implementation VATool

+ (VAUserModel *)fetchUserInfo
{
    VAUserModel *user = nil;
    
    return user;
}

+ (UILabel *)getLabelWithTextString:(NSString *)textString
                           fontSize:(float)fontSize
                          textColor:(UIColor *)textColor
                              sapce:(float)lineSpace
                               bold:(BOOL)isBold
{
    UILabel *label = [[UILabel alloc] init];
    label.font = isBold ? DEFAULT_BOLD_FONT(fontSize) : DEFAULT_FONT(fontSize);
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    if (!textString) textString = @"";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:lineSpace];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textString length])];
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, textString.length)];
    
    label.attributedText = attributedString;
    
    [label sizeToFit];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

+ (void)addCalendarEventWithStartTime:(long long)startTime sessionType:(TMNClassSessionType)sessionType
{
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        
        int timeInterval;
        switch (sessionType) {
            case TMNClassSessionType_1on1:
                timeInterval = 45;
                break;
            case TMNClassSessionType_1on2:
                timeInterval = 45;
                break;
            case TMNClassSessionType_1on3:
                timeInterval = 45;
                break;
            case TMNClassSessionType_1on4:
                timeInterval = 45;
                break;
            case TMNClassSessionType_1on6:
                timeInterval = 45;
                break;
            case TMNClassSessionType_Lobby10:
                timeInterval = 10;
                break;
            case TMNClassSessionType_Lobby20:
                timeInterval = 20;
                break;
            case TMNClassSessionType_Lobby45:
                timeInterval = 45;
                break;
            case TMNClassSessionType_PowerSession:
                timeInterval = 45;
                break;
            default:
                timeInterval = 45;
                break;
        }
        
        
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime / 1000];
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = @"vipabc提醒您快要上课咯";
        event.startDate = startDate;
        event.endDate = [event.startDate dateByAddingTimeInterval:60 * timeInterval];
        event.calendar = [store defaultCalendarForNewEvents];
        [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[startDate dateByAddingTimeInterval:-15 * 60]]];   //提前15分钟提醒
        [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[startDate dateByAddingTimeInterval:-60 * 60]]];   //提前60分钟提醒
        
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        [kUserDefaults setObject:event.eventIdentifier forKey:[NSString stringWithFormat:@"%lld", startTime]];
        [kUserDefaults synchronize];
    }];
}

+ (void)removeCalendar:(long long)startTime;
{
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        NSError *err = nil;
        NSString *eventIdentifier = [kUserDefaults objectForKey:[NSString stringWithFormat:@"%lld", startTime]];
        
        if (eventIdentifier == nil || [@"" isEqualToString:eventIdentifier])
            return;
        
        [store removeEvent:[store eventWithIdentifier:eventIdentifier] span:EKSpanThisEvent error:&err];
        
        [kUserDefaults removeObjectForKey:[NSString stringWithFormat:@"%lld", startTime]];
        [kUserDefaults synchronize];
    }];
}

+ (void)sendCall:(NSString *)phoneNo withParentView:(UIView *)parentView
{
    UIWebView *webView = [[UIWebView alloc] init];
    
    if (phoneNo == nil || [@"" isEqualToString:phoneNo])
        phoneNo = @"4006-30-30-30";
        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNo]];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    webView.hidden = NO;
    [parentView addSubview:webView];
}

+ (void)setStatusBarWithColor:(UIColor *)color style:(UIStatusBarStyle)statusBarStyle;
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    view.backgroundColor = color;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController.view addSubview:view];
    [UIApplication sharedApplication].statusBarStyle = statusBarStyle;
}

+ (NSString *)fetchMessageWithCode:(NSString *)code;
{
    NSString *resultMessage = @"连接异常，请重新再试。";
    
    NSDictionary *messageDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCommonMessagesKey];
    
    if (messageDic != nil) {
        NSString *message = [messageDic objectForKey:code];
        
        if (message != nil && ![@"" isEqualToString:message]) {
            resultMessage = message;
        }
    }
    
    return resultMessage;
}

+ (void)shareToWeiXinWithSence:(int)scene title:(NSString *)title content:(NSString *)content thumbImage:(UIImage *)thumbImage url:(NSString *)urlString shareImage:(UIImage *)shareImage
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = scene;
    req.message = WXMediaMessage.message;
    req.message.title = title;
    req.message.description = content;
    
    if (thumbImage) {
        CGFloat width = 100.0f;
        CGFloat height = thumbImage.size.height * 100.0f / thumbImage.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [thumbImage drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [req.message setThumbImage:scaledImage];
    }
    
    if (urlString) {
        WXWebpageObject *webObject = WXWebpageObject.object;
        webObject.webpageUrl = [[NSURL URLWithString:urlString] absoluteString];
        req.message.mediaObject = webObject;
    } else if (shareImage) {
        WXImageObject *imageObject = WXImageObject.object;
        imageObject.imageData = UIImageJPEGRepresentation(shareImage, 1);
        req.message.mediaObject = imageObject;
    }
    
    BOOL result = [WXApi sendReq:req];
}

+ (BOOL)hasMicrophonePermission
{
    __block BOOL result = YES;
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        result = granted;
    }];
    
    return result;
}

+ (NSString *)fetchDailyWord
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *dailyWord = [userDefault objectForKey:kDailyWord];
    if (dailyWord == nil || [@"" isEqualToString:dailyWord])
        dailyWord = @"Life is too important to be taken seriously.";
    
    return dailyWord;
}

+ (NSString *)fetchDailyWordAuthor
{
    NSString *author = [kUserDefaults objectForKey:kDailyWordAuthor];
    if (author == nil || [@"" isEqualToString:author])
        author = @"Wilde Oscar";
    
    return author;
}

+ (UIImage *)fetchDailyImage
{
    NSString *documentPath = [[NSString stringWithFormat:@"%@", NSTemporaryDirectory()] stringByAppendingPathComponent:kDailyImageName];
    
    UIImage *dailyImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:documentPath]];
    
    
    if (dailyImage == nil) {
        NSString *imageName = @"";
        if (iPhone4)
            imageName = @"VALaunch2Background_4";
        else if (iPhone5)
            imageName = @"VALaunch2Background_5";
        else if (iPhone6)
            imageName = @"VALaunch2Background_6";
        
        dailyImage = [UIImage imageNamed:imageName];
    }
    
    return dailyImage;
}

+ (BOOL)isRegisterOpen
{
    if ([[[kUserDefaults objectForKey:kConfigureInfo] objectForKey:@"IsRegisterOpen"] intValue] == 1)
        return YES;
    else
        return NO;
}

+ (BOOL)needCalendarNotification
{
    NSString *needCalendarNotification = [kUserDefaults objectForKey:kCalendarNotification];
    if ([@"close" isEqualToString:needCalendarNotification])
        return NO;
    else
        return YES;
}

+ (NSString *)fetchServiceTelphone
{
    NSString *telphone = [kUserDefaults objectForKey:kServiceTelphone];
    
    if (telphone == nil || [@"" isEqualToString:telphone])
        telphone = @"4006-30-30-30";
    
    return telphone;
}
@end
