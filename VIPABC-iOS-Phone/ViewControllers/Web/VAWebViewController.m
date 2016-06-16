//
//  VAWebViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 15/12/29.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VAWebViewController.h"
#import "VAWebViewURLProtocol.h"
#import <objc/runtime.h>
#import "TMNNetworkLogicController.h"
#import "TMNNetworkLogicManager.h"
#import "JSONKit.h"
#import "NSObject+MJKeyValue.h"
#import "VALoginViewController.h"
#import "TMLesson.h"
#import "VAClassPreparationViewController.h"
#import "TMNextSessionInfo.h"
#import "TMClassInfo.h"
#import "VATool.h"
#import "TMConsultant.h"
#import "VANetworkInterface.h"
#import "VACustomerNavigationController.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"
#import "WXApi.h"
#import "RecordedSessionType1ViewController.h"

@interface VAWebViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) TMNNetworkLogicController *network;
@property (nonatomic, copy) NSString *homePageHtmlPath;
@property (nonatomic, copy) NSString *middlePageHtmlPath;
@property (nonatomic, copy) NSString *userCenterHtmlPath;
@property (nonatomic, copy) NSString *h5ServerURL;

@end

@implementation VAWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
    
    self.network = [TMNNetworkLogicManager sharedInstace];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    [NSURLProtocol registerClass:[VAWebViewURLProtocol class]];
    //    [NSURLProtocol unregisterClass:[VAWebViewController class]];
//    self.htmlPath = [NSString stringWithFormat:@"%@/lisener/index.html", @"http://192.168.142.238"];
    self.h5ServerURL = [kUserDefaults objectForKey:kH5ServerURL];
    self.homePageHtmlPath = [NSString stringWithFormat:@"%@/vproject/demonstrationClass.html", _h5ServerURL];
    self.middlePageHtmlPath = [NSString stringWithFormat:@"%@/lisener/index.html", _h5ServerURL];
    self.userCenterHtmlPath = [NSString stringWithFormat:@"%@/vproject/memberCenter.html", _h5ServerURL];
    
//    [self navigateToVideoRecordPage];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 进首页、个人中心清除缓存
    if ([_homePageHtmlPath isEqualToString:self.htmlPath] || [_userCenterHtmlPath isEqualToString:self.htmlPath]) {
//        [self.webView stringByEvaluatingJavaScriptFromString:@"clearSession();"];
    }
    
    // 查询是否有订课信息，如果有跳转到订课页面
    if ([_middlePageHtmlPath isEqualToString:self.htmlPath]) {
        
        // 进上课清除缓存
//        [self.webView stringByEvaluatingJavaScriptFromString:@"clearSession();"];
        
        TMUser *currentUser = [self.network currentUser];
        if (currentUser == nil) {
//            [self navigateToLogin];
            return;
        }
        
        // 第一次点击中间的tab 请求学习历程接口
        if ([@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kShowClassPreparationPage]]) {
            [self getPlan];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kShowClassPreparationPage];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    if (self.needNavigateToEvaluatePage) {
        [self webViewLoadhtml:self.evaluatePage];
        self.needNavigateToEvaluatePage = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    [currentDevice setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
//    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    
    [self webViewLoadhtml:self.htmlPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewLoadhtml:(NSString *)html
{
//    NSString *htmlPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:html];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:html]];//@"http://192.168.142.238/lisener/index.html"]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [self.webView loadRequest:request];
}

- (void)fetchConfigure
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    [VANetworkInterface fetchConfigureWithVersion:[[mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"] appName:[[mainBundle infoDictionary] objectForKey:@"CFBundleName"] platForm:@"ios" deviceType:@"iphone" language:@"zh-cn" successBlock:^(id responseObject) {
        NSLog(@"");
    } failedBlock:^(NSError *error, id responseObject) {
        NSLog(@"");
    }];
}

// 获取学习历程
- (void)getPlan
{
    [SVProgressHUD show];
    
    [self.network getPlanWithBeginTime:[[NSDate date] timeIntervalSince1970] endTime:[[NSDate dateWithTimeIntervalSinceNow:60 * 60] timeIntervalSince1970] successBlock:^(NSArray *responseArray) {
        BOOL needDismissHUD = YES;
//        NSString *hasTappedWaitButton = [[NSUserDefaults standardUserDefaults] objectForKey:kHasTappedWaitButton];
        for (TMLesson *lesson in responseArray) {
            if (lesson.status == TMLessonPlanStatus_Can_Enter || (lesson.status == TMLessonPlanStatus_Can_Review )) { //&& ![@"1" isEqualToString:hasTappedWaitButton]
                [self navigateToClassPreparationPageWithSessionSn:lesson.sessionSn];
                needDismissHUD = NO;
                break;
            }
        }
        
        if (needDismissHUD)
            [SVProgressHUD dismiss];
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
}

- (void)navigateToClassPreparationPageWithSessionSn:(NSString *)sessionSn
{
    [SVProgressHUD show];
    [self.network getClassInfoWithSn:sessionSn successBlock:^(id object) {
        
        TMClassInfo *classInfo = (TMClassInfo *)object;
        VAClassPreparationViewController *viewController = [[VAClassPreparationViewController alloc] init];
        viewController.classInfo = classInfo;
        [SVProgressHUD show];
        if (classInfo.consultantSn) {
            [self.network getConsultantInfoWithSn:classInfo.consultantSn successBlock:^(id object) {
                [SVProgressHUD dismiss];
                TMConsultant *consultant = (TMConsultant *)object;
                viewController.consultant = consultant;
                
                VACustomerNavigationController *navigationViewController = [[VACustomerNavigationController alloc] initWithRootViewController:viewController];
                [self presentViewController:navigationViewController animated:NO completion:nil];
            } failedBlock:^(NSError *error, id responseObject) {
                [SVProgressHUD showErrorWithStatus:responseObject];
            }];
        }
        else
            [SVProgressHUD dismiss];
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
}

/**
 * Login
 */
- (void)navigateToLogin
{
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"account"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUserKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kShowClassPreparationPage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    VALoginViewController *loginViewController = [[VALoginViewController alloc] init];
    VACustomerNavigationController *navigationVC = [[VACustomerNavigationController alloc] initWithRootViewController:loginViewController];
    
    [self presentViewController:navigationVC animated:YES completion:nil];
}

- (void)makeTabBarHidden
{
    [UIView animateWithDuration:0.2 animations:^{
        UITabBar *tb = self.tabBarController.tabBar;
        tb.frame = CGRectMake(tb.frame.origin.x, kScreenHeight, tb.frame.size.width, tb.frame.size.height);
        
        [self.webView.scrollView setContentInset:UIEdgeInsetsMake(self.webView.scrollView.contentInset.top, 0, 0, 0)];
    }];
}

- (void)makeTabBarShow
{
    [UIView animateWithDuration:0.2 animations:^{
        UITabBar *tb = self.tabBarController.tabBar;
        tb.frame = CGRectMake(tb.frame.origin.x, kScreenHeight - tb.frame.size.height, tb.frame.size.width, tb.frame.size.height);
        
        [self.webView.scrollView setContentInset:UIEdgeInsetsMake(self.webView.scrollView.contentInset.top, 0, tb.bounds.size.height, 0)];
    }];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"request url: %@", request.URL);
    NSString *scheme = request.URL.scheme;
    NSString *urlString = [NSString stringWithFormat:@"%@", request.URL];
    if ([urlString hasPrefix:_h5ServerURL] || [urlString hasPrefix:@"http://192.168.142.238"] || [urlString hasPrefix:@"http://res.vipabc.com/"] || [urlString hasPrefix:@"http://www.tutormeet.com"] || [urlString hasPrefix:@"http://h5.vipabc.com"])
        return YES;
    else if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    else if ([scheme isEqualToString:@"vipabc"]) {
        NSString *host = request.URL.host;
        // 获取用户信息
        if ([host isEqualToString:@"fetchUserInfo"]) {
            // 用户未登录、跳转到登录页面（排除首页）
            if ([self isLogOut] && ![_homePageHtmlPath isEqualToString:self.htmlPath]) {
                [self navigateToLogin];
                return NO;
            }
            
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"fetchUserInfoResponse('%@');", [[[TMNNetworkLogicManager sharedInstace] currentUser] JSONString]]];
            
            return NO;
        }
        // 跳转到登录页
        else if ([host isEqualToString:@"navigateToLogin"]) {
            [self navigateToLogin];
            
            return NO;
        }
        // 隐藏Tab bar
        else if ([host isEqualToString:@"hideTabBar"]) {
            [self makeTabBarHidden];
            return NO;
        }
        // 显示 Tab bar
        else if ([host isEqualToString:@"showTabBar"]) {
            [self makeTabBarShow];
            return NO;
        }
        // 跳转url
        else if ([host isEqualToString:@"href"]) {
            NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"locationHref();"];
            [self webViewLoadhtml:html];
            return NO;
        }
        // 显示 Status bar 阴影
        else if ([host isEqualToString:@"showStatusBarShadow"]) {
            [VATool setStatusBarWithColor:RGBCOLOR(0, 0, 0, 0.4) style:UIStatusBarStyleLightContent];
        }
        // 去除 Status bar 阴影
        else if ([host isEqualToString:@"removeStatusBarShadow"]) {
            [VATool setStatusBarWithColor:RGBCOLOR(247, 76, 76, 1) style:UIStatusBarStyleLightContent];
        }
        // 呼叫客服
        else if ([host isEqualToString:@"call"]) {
            [VATool sendCall:[VATool fetchServiceTelphone] withParentView:self.view];
            return NO;
        }
        // 获取客服电话
        else if ([host isEqualToString:@"fetchServiceTelphone"]) {
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setServiceTelphone('%@');", [VATool fetchServiceTelphone]]];
            return NO;
        }
        // 跳转到教材预览页面
        else if ([host isEqualToString:@"navigateToClassPreparationPage"]) {
            [self navigateToClassPreparationPageWithSessionSn:[webView stringByEvaluatingJavaScriptFromString:@"fetchSessonSn();"]];
            return NO;
        }
        // 获取错误信息
        else if ([host isEqualToString:@"fetchErrorMessage"]) {
            [VATool fetchMessageWithCode:[webView stringByEvaluatingJavaScriptFromString:@"fetchMessageCode();"]];
            return NO;
        }
        // 获取H5服务器地址
        else if ([host isEqualToString:@"fetchH5ServerURL"]) {
            [self handleJavaScriptWithName:@"setH5ServerURL" data:_h5ServerURL];
            return NO;
        }
        // 获取后台服务器地址
        else if ([host isEqualToString:@"fetchAPIServerURL"]) {
            [self handleJavaScriptWithName:@"setAPIServerURL" data:[kUserDefaults objectForKey:kApiServerURL]];
            return NO;
        }
        // 获取是否开启上课提醒
        else if ([host isEqualToString:@"needCalendarNotification"]) {
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"needCalendarNotification('%@');", [VATool needCalendarNotification] ? @"open" : @"close"]];
            return NO;
        }
        // 开启上课提醒
        else if ([host isEqualToString:@"openCalendarNotification"]) {
            [kUserDefaults setObject:@"open" forKey:kCalendarNotification];
            return NO;
        }
        // 关闭上课提醒
        else if ([host isEqualToString:@"closeCalendarNotification"]) {
            [kUserDefaults setObject:@"close" forKey:kCalendarNotification];
            return NO;
        }
        // 分享
        else if ([host isEqualToString:@"share"]) {
//            if (![VATool isRegisterOpen])
//                return NO;
            
            NSString *parameters = [webView stringByEvaluatingJavaScriptFromString:@"getShareParameters();"];
            
            if (parameters == nil || [@"" isEqualToString:parameters])
                return NO;
            
            NSArray *shareParameters = [parameters componentsSeparatedByString:@"#"];
            
            NSString *sence = [[shareParameters objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            int senceValue;
            // 微信朋友
            if ([@"WXSceneSession" isEqualToString:sence]) {
                senceValue = WXSceneSession;
            }
            // 微信朋友圈
            else if ([@"WXSceneTimeline" isEqualToString:sence]) {
                senceValue = WXSceneTimeline;
            }
            
            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[shareParameters objectAtIndex:4]]]];
            
            [self shareToWeiXinWithSence:senceValue title:[shareParameters objectAtIndex:1] content:[shareParameters objectAtIndex:2] thumbImage:thumbImage url:[shareParameters objectAtIndex:3] shareImage:nil];
            
            if (shareParameters.count > 5) {
                NSString *hasShareReward = [shareParameters objectAtIndex:5];
                if ([@"hasShareReward" isEqualToString:hasShareReward]) {
                    
                    [VANetworkInterface rewardInviterWithClientSn:[self.network currentUser].clientSn successBlock:^(id responseObject) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                        [alertView show];
                    } failedBlock:^(NSError *error, id responseObject) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:responseObject delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                        [alertView show];
                    }];
                }
            }
            
            return NO;
        }
        // 麦克风检测
        else if ([host isEqualToString:@"checkMicrophonePermission"]) {
            [self checkMicroPhonePermission];
            return NO;
        }
        // 上课录像
        else if ([host isEqualToString:@"navigateToVideoRecordPage"]) {
            [self navigateToVideoRecordPage];
            return NO;
        }
        // 发送网络请求
        else if ([host isEqualToString:@"sendRequest"]) {
            
            // 用户未登录、跳转到登录页面
            if ([self isLogOut]) {
                [self navigateToLogin];
                return NO;
            }
            
            if (![VANetworkInterface isNetworkReachable]) {
                [SVProgressHUD showErrorWithStatus:@"请检查您的网络设置！"];
                return NO;
            }
            
            NSString *parameters = [webView stringByEvaluatingJavaScriptFromString:@"fetchParameters();"];
            
            NSDictionary *dic = [parameters objectFromJSONString];
            
            // API参数
            NSArray *methodParameters = [dic objectForKey:@"parameters"];
            // API名称
            NSString *method = [dic objectForKey:@"method"];
            // 返回Method
            NSString *responseMethod = [dic objectForKey:@"responseMethod"];
            
            //            SEL selector = NSSelectorFromString(method);
            
            NSLog(@"fetchParameters: %@", parameters);
            
            BOOL showLoading = YES;
            
            NSString *urlString = [NSString stringWithFormat:@"%@", request.URL];
            if ([urlString hasSuffix:@"NO"])
                showLoading = NO;
            
            // 获取课程列表   http://192.168.23.109:8018/mobcommon/webapi/session/1/getTimeTbl?
            if ([@"getTimeTblWithClientSn:brandId:sessionType:beginTime:endTime:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSString *clientSn = [methodParameters objectAtIndex:0];
                int brandId = [[methodParameters objectAtIndex:1] intValue];
                int sessionType = [[methodParameters objectAtIndex:2] intValue];
                long long beginTime = [[methodParameters objectAtIndex:3] longLongValue];
                long long endTime = [[methodParameters objectAtIndex:4] longLongValue];
                
                [self.network getTimeTblWithClientSn:clientSn brandId:brandId sessionType:sessionType beginTime:beginTime endTime:endTime successBlock:^(NSArray *responseArray) {
                    DDLogDebug(@"%@", responseArray);
                    NSMutableArray *tempArray = [NSMutableArray array];
                    
                    for (NSObject *object in responseArray) {
                        [tempArray addObject:[object JSONString]];
                    }
                    
                    [self handleJavaScriptWithName:responseMethod data:[tempArray JSONString]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            //取得课程咨询
            else if ([@"getClassInfoWithSn:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSString *sessionSn = [methodParameters objectAtIndex:0];
                
                NSLog(@"===============getClassInfoWithSn start");
                [self.network getClassInfoWithSn:sessionSn successBlock:^(id object) {
                    NSLog(@"===============getClassInfoWithSn end");
                    DDLogDebug(@"%@", object);
                    [self handleJavaScriptWithName:responseMethod data:[object JSONString]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 超值订课
            else if ([@"sendClassInfo:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSMutableArray *classInfo = [methodParameters objectAtIndex:0];
                
                NSMutableArray *paramsArray = [NSMutableArray array];
                
                for (NSDictionary *dic in classInfo) {
                    TMLesson *lesson = [[TMLesson alloc] init];
                    lesson.startTime = [[dic objectForKey:@"startTime"] longLongValue];
                    lesson.sessionType = [[dic objectForKey:@"sessionType"] integerValue];
                    
                    Classdetail *classDetail = [[Classdetail alloc] init];
                    classDetail.lobbySn = [[dic objectForKey:@"lobbySn"] integerValue];
                    lesson.classDetail = classDetail;
                    
                    [paramsArray addObject:lesson];
                }
                
                [self.network sendClassInfo:paramsArray successBlock:^(id object) {
                    DDLogDebug(@"%@", object);
                    if ([VATool needCalendarNotification])
                        [VATool addCalendarEventWithStartTime:[[object objectForKey:@"startTime"] longLongValue] sessionType:[object objectForKey:@"sessionType"]];
                    [self handleJavaScriptWithName:responseMethod data:[self dataToJSONString:object]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[self dataToJSONString:responseObject]];
                }];
            }
            // 一般订课
            else if ([@"reserveLessons:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSMutableArray *classInfo = [methodParameters objectAtIndex:0];
                
                NSMutableArray *paramsArray = [NSMutableArray array];
                
                for (NSDictionary *dic in classInfo) {
                    TMLesson *lesson = [[TMLesson alloc] init];
                    lesson.startTime = [[dic objectForKey:@"startTime"] longLongValue];
                    lesson.sessionType = [[dic objectForKey:@"sessionType"] integerValue];
                    
                    Classdetail *classDetail = [[Classdetail alloc] init];
                    classDetail.lobbySn = [[dic objectForKey:@"lobbySn"] integerValue];
                    lesson.classDetail = classDetail;
                    [paramsArray addObject:lesson];
                }
                
                [self.network reserveLessons:paramsArray successBlock:^(NSArray *responseArray) {
                    NSMutableArray *tempArray = [NSMutableArray array];
                    
                    for (NSObject *object in responseArray) {
                        if ([object isKindOfClass:TMLessonResponse.class]) {
                            TMLessonResponse *lessonResp = (TMLessonResponse *) object;
                            if (lessonResp.isSuccess && [VATool needCalendarNotification])
                                [VATool addCalendarEventWithStartTime:lessonResp.startTime sessionType:lessonResp.sessionType];
                        }
                        
                        [tempArray addObject:[object JSONString]];
                    }
                    
                    [self handleJavaScriptWithName:responseMethod data:[tempArray JSONString]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:responseObject];
                }];
            }
            // 取消订课
            else if ([@"cancelLesson:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSMutableArray *classInfo = [methodParameters objectAtIndex:0];
                
                NSMutableArray *paramsArray = [NSMutableArray array];
                
                for (NSDictionary *dic in classInfo) {
                    TMLesson *lesson = [[TMLesson alloc] init];
                    lesson.startTime = [[dic objectForKey:@"startTime"] longLongValue];
                    
                    [paramsArray addObject:lesson];
                }
                
                [self.network cancelLesson:paramsArray successBlock:^(NSArray *responseArray) {
                    DDLogDebug(@"%@", responseArray);
                    NSMutableArray *tempArray = [NSMutableArray array];
                    
                    for (NSObject *object in responseArray) {
                        [tempArray addObject:[object JSONString]];
                        
                        if ([object isKindOfClass:TMLessonResponse.class]) {
                            TMLessonResponse *lesssonResponse = (TMLessonResponse *)object;
                            [VATool removeCalendar:lesssonResponse.startTime];
                        }
                    }
                    
                    [self handleJavaScriptWithName:responseMethod data:[tempArray JSONString]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:responseObject];
                }];
            }
            // 登录
            else if ([@"loginWithAccount:password:brandId:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSString *account = [methodParameters objectAtIndex:0];
                NSString *password = [methodParameters objectAtIndex:1];
                int brandID = [[methodParameters objectAtIndex:2] intValue];
                [self.network loginWithAccount:account password:password brandId:brandID successBlock:^(id object) {
                    DDLogDebug(@"%@", object);
                    [self handleJavaScriptWithName:responseMethod data:[object JSONString]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 获取客户复习列表
            else if ([@"getVideoRecordsWithPage:recordCount:startDate:endDate:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                int page = [[methodParameters objectAtIndex:0] intValue];
                int count = [[methodParameters objectAtIndex:1] intValue];
                NSString *startDate = [methodParameters objectAtIndex:2];
                NSString *endDate = [methodParameters objectAtIndex:3];
                [self.network getVideoRecordsWithPage:page recordCount:count startDate:startDate endDate:endDate successBlock:^(NSDictionary *responseDic) {
                    [self handleJavaScriptWithName:responseMethod data:[self dataToJSONString:responseDic]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[responseObject JSONString]];
                }];
            }
            // 获取Video
            else if ([@"getVideoInfoWithfileSn:materialSn:sessionSn:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                int fileSn = [[methodParameters objectAtIndex:0] intValue];
                int materialSn = [[methodParameters objectAtIndex:1] intValue];
                NSString *sessionSn = [methodParameters objectAtIndex:2];
                [self.network getVideoInfoWithfileSn:fileSn materialSn:materialSn sessionSn:sessionSn successBlock:^(id object) {
                    DDLogDebug(@"%@", object);
                    [self handleJavaScriptWithName:responseMethod data:[self dataToJSONString:object]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 单词预览
            else if ([@"getVocabularyListWithBrandId:materialSn:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                int brandID = [[methodParameters objectAtIndex:0] intValue];
                NSString *materialSn = [methodParameters objectAtIndex:1];
                
                [self.network getVocabularyListWithBrandId:brandID materialSn:materialSn successBlock:^(NSDictionary *responseDic) {
                    DDLogDebug(@"%@", responseDic);
                    [self handleJavaScriptWithName:responseMethod data:[self dataToJSONString:responseDic]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 获取合约资讯
            else if ([@"getContractInfoWithSuccessBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                [self.network getContractInfoWithSuccessBlock:^(NSArray *responseArray) {
                    DDLogDebug(@"%@", responseArray);
                    NSMutableArray *tempArray = [NSMutableArray array];
                    
                    for (NSObject *object in responseArray) {
                        [tempArray addObject:[object JSONString]];
                    }
                    
                    [self handleJavaScriptWithName:responseMethod data:[tempArray JSONString]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 获取学习计划
            else if ([@"getPlanWithBeginTime:endTime:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                long long beginTime = [[methodParameters objectAtIndex:0] longLongValue];
                long long endTime = [[methodParameters objectAtIndex:1] longLongValue];
                [self.network getPlanWithBeginTime:beginTime endTime:endTime successBlock:^(NSArray *responseArray) {
                    DDLogDebug(@"%@", responseArray);
                    NSMutableArray *tempArray = [NSMutableArray array];
                    
                    for (NSObject *object in responseArray) {
                        [tempArray addObject:[object JSONString]];
                    }
                    
                    [self handleJavaScriptWithName:responseMethod data:[tempArray JSONString]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 送出评价
            else if ([@"sendRatingInfoWithSn:rating:suggestion:compliment:isContactClient:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSString *sessionSn = [methodParameters objectAtIndex:0];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[methodParameters objectAtIndex:1]];
                NSString *suggestion = [methodParameters objectAtIndex:2];
                NSString *compliment = [methodParameters objectAtIndex:3];
                BOOL isContactClient = [[methodParameters objectAtIndex:4] boolValue];
                [self.network sendRatingInfoWithSn:sessionSn rating:dic suggestion:suggestion compliment:compliment isContactClient:isContactClient successBlock:^(id object) {
                    [self handleJavaScriptWithName:responseMethod data:[self dataToJSONString:object]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 查询评价列表
            else if ([@"getClassListWithPageSize:pageIndex:startTime:endTime:isDesc:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                int pageSize = [[methodParameters objectAtIndex:0] intValue];
                int pageIndex = [[methodParameters objectAtIndex:1] intValue];
                NSString *startTime = [methodParameters objectAtIndex:2];
                NSString *endTime = [methodParameters objectAtIndex:3];
                BOOL isDesc = [[methodParameters objectAtIndex:4] boolValue];
                
                [self.network getClassListWithPageSize:pageSize pageIndex:pageIndex startTime:startTime endTime:endTime isDesc:isDesc successBlock:^(NSDictionary *responseDic) {
                    [self handleJavaScriptWithName:responseMethod data:[self dataToJSONString:responseDic]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 查询评价咨询
            else if ([@"getReviewRatingInfoWithSn:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSString *sessionSn = [methodParameters objectAtIndex:0];
                [self.network getReviewRatingInfoWithSn:sessionSn successBlock:^(id object) {
                    [self handleJavaScriptWithName:responseMethod data:[self dataToJSONString:object]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            // 获取顾问资讯
            else if ([@"getConsultantInfoWithSn:successBlock:failedBlock:" isEqualToString:method]) {
                [self showLoadingView:showLoading];
                
                NSString *consultantSn = [methodParameters objectAtIndex:0];
                
                NSLog(@"==========getConsultantInfoWithSn start");
                [self.network getConsultantInfoWithSn:consultantSn successBlock:^(id object) {
                    NSLog(@"==========getConsultantInfoWithSn end");
                    [self handleJavaScriptWithName:responseMethod data:[object JSONString]];
                } failedBlock:^(NSError *error, id responseObject) {
                    DDLogDebug(@"%@", responseObject);
                    [self handleJavaScriptWithName:responseMethod data:[NSString stringWithFormat:@"%@", responseObject]];
                }];
            }
            
            return NO;
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    
}

- (void)showRecordSessionType1WithClassInfo:(NSDictionary *)classInfo {
    __weak id weakSelf = self;
    if (classInfo) {
        NSString *server = classInfo[@"server"];
        NSString *sessionSn = classInfo[@"sessionSn"];
        RecordedSessionType1ViewController *viewController = [[RecordedSessionType1ViewController alloc] initWithServer:server sessionSn:sessionSn classStartMin:@"45" ];
        
        VACustomerNavigationController *navigationViewController = [[VACustomerNavigationController alloc] initWithRootViewController:viewController];
        navigationViewController.onlyLandscape = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:navigationViewController animated:YES completion:nil];
        });
        
    } else {
        NSLog(@"No class info");
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:@"No Class info"];
        });
    }
}

- (NSMutableDictionary *)test:(NSString *)str
{
    if ([self isValidUrl:str]) {
            NSString *query = [[str componentsSeparatedByString:@"?"] lastObject];
            NSArray *queryParams = [query componentsSeparatedByString:@"&"];
            NSMutableDictionary *dictParams = [[NSMutableDictionary alloc] init];
            for (NSString *param in queryParams) {
                NSArray *keyValuePair = [param componentsSeparatedByString:@"="];
                NSString *key = [keyValuePair firstObject];
                NSString *value = [keyValuePair lastObject];
                
                [dictParams setValue:value forKey:key];
            }
            return dictParams;
        }
        return nil;
}

- (BOOL)isValidUrl:(NSString *)str {
    NSError *error = NULL;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"(?i)(?:(?:https?):\\/\\/)?(?:\\S+(?::\\S*)?@)?(?:(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\u00a1-\\uffff0-9]+-?)*[a-z\\u00a1-\\uffff0-9]+)(?:\\.(?:[a-z\\u00a1-\\uffff0-9]+-?)*[a-z\\u00a1-\\uffff0-9]+)*(?:\\.(?:[a-z\\u00a1-\\uffff]{2,})))(?::\\d{2,5})?(?:\\/[^\\s]*)?" options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
        NSLog(@"error");
    NSRange range = [expression rangeOfFirstMatchInString:str
                                                  options:NSMatchingReportCompletion
                                                    range:NSMakeRange(0, [str length])];
    if (!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))){
        NSString *match = [str substringWithRange:range];
        NSLog(@"%@", match);
        return YES;
    }
    else {
        NSLog(@"no match");
        return NO;
    }
}

#pragma mark - Webview execute javascript
- (void)handleJavaScriptWithName:(NSString *)methodName data:(NSString *)data
{
    [SVProgressHUD dismiss];
    
    data = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    data = [[data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSString *javascriptString = [NSString stringWithFormat:@"%@('%@');", methodName, data];
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptString];
}

- (NSString*)dataToJSONString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (void)showLoadingView:(BOOL)showLoading
{
    if (showLoading)
        [SVProgressHUD show];
}

#pragma mark -
- (BOOL)isLogOut
{
    BOOL result = NO;
    
    TMUser *user = [self.network currentUser];
    
    if (!user)
        result = YES;
    
    return result;
}

#pragma mark - 
- (void)navigateToVideoRecordPage
{
    [SVProgressHUD show];
    
    NSString *parameters = [self.webView stringByEvaluatingJavaScriptFromString:@"fetchVideoPageParameters();"];
    
    NSDictionary *dic = [parameters objectFromJSONString];
    
    // API参数
    NSArray *methodParameters = [dic objectForKey:@"parameters"];
    
    int fileSn = [[methodParameters objectAtIndex:0] intValue];
    int materialSn = [[methodParameters objectAtIndex:1] intValue];
    NSString *sessionSn = [methodParameters objectAtIndex:2];
    [self.network getVideoInfoWithfileSn:fileSn materialSn:materialSn sessionSn:sessionSn successBlock:^(id object) {
        DDLogDebug(@"%@", object);
        
        NSString *recordingUrl = [object objectForKey:@"recordingUrl"];// @"http://www.tutormeet.com/tutormeet/tutormeet.html?playback=1&file_name=_recording_session750_e4Ci6D7LPc_2016022417750&user_sn=1673378&compStatus=abc&comp_status_logo=undefined&playtype=1";//
        
        if (nil != recordingUrl && ![recordingUrl isEqualToString:@""]) {
            
            NSDictionary *recordingData = [self test:recordingUrl];
            NSURLComponents *url = [[NSURLComponents alloc] initWithString:@"http://www.tutormeet.com/tutormeetweb/record.do"];
            url.queryItems = @[[NSURLQueryItem queryItemWithName:@"action" value:@"getRecoding"],
                               [NSURLQueryItem queryItemWithName:@"fileName" value:[recordingData objectForKey:@"file_name"]],
                               [NSURLQueryItem queryItemWithName:@"clientSn" value:[self.network currentUser].clientSn],
                               [NSURLQueryItem queryItemWithName:@"comp_status" value:[recordingData objectForKey:@"compStatus"]]];
            
            NSLog(@"record.do url: %@", url);
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSLog(@"error: %@", error.localizedDescription);
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"login.do: %@", json);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    NSLog(@"record.do reponse:%@", data);
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSString *sessionSn = [[[json objectForKey:@"videoName"] componentsSeparatedByString:@"_"] lastObject];
                    NSString *serverIP = [json objectForKey:@"serverIP"];
                    NSDictionary *classInfo = @{@"server": serverIP, @"sessionSn": sessionSn};
                    [self showRecordSessionType1WithClassInfo:classInfo];
                });
                
            }];
            [dataTask resume];
        }
        else
            [SVProgressHUD showErrorWithStatus:@"录像正在准备中"];
    } failedBlock:^(NSError *error, id responseObject) {
        DDLogDebug(@"%@", responseObject);
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
}

#pragma mark - Autorotate
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Share
- (void)shareToWeiXinWithSence:(int)scene title:(NSString *)title content:(NSString *)content thumbImage:(UIImage *)thumbImage url:(NSString *)urlString shareImage:(UIImage *)shareImage;
{
    [VATool shareToWeiXinWithSence:scene title:title content:content thumbImage:thumbImage url:urlString shareImage:shareImage];
}

#pragma mark - check microphone permission
- (void)checkMicroPhonePermission
{
    if ([VATool hasMicrophonePermission]) {
        [SVProgressHUD showSuccessWithStatus:@"恭喜您，设备检查通过！"];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"麦克风不可用" message:@"请至iPhone的“设置-隐私-麦克风”中，允许vipabc访问麦克风" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
@end
