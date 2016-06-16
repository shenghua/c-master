//
//  AppDelegate.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/13.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "AppDelegate.h"
#import "VATabBarViewController.h"
//#import "CocoaLumberjack.h"
#import "AFNetworkReachabilityManager.h"
#import "TMNNetworkLogicController.h"
#import "TMNNetworkLogicManager.h"
#import "VALaunch2ViewController.h"
#import "VATool.h"
#import "VAWebViewController.h"
#import "VANetworkInterface.h"
#import "JSONKit.h"
#import "WXApi.h"
#import "VAFirstOpenViewController.h"

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Console.app日志
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    // Xcode控制台日志
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    // 启动网络监听
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 初始化弹出框样式
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    // 初始化微信SDK
    [WXApi registerApp:kWXAppId];
    
    // 注册通知
//    [self procRegisterRemoteNotification];
    
    [NSThread sleepForTimeInterval:1.5];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kHasTappedWaitButton];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kShowClassPreparationPage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.window makeKeyAndVisible];
    
    [self initNetwork];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - page navigation
- (void)navigateToTabBarPage
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    VATabBarViewController *tapViewController = [[VATabBarViewController alloc] init];
    self.window.rootViewController = tapViewController;
    
    // status bar color
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    view.backgroundColor = RGBCOLOR(238, 238, 238, 1);
    [self.window.rootViewController.view addSubview:view];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)navigateToEvaluatePage:(NSString *)sessionSn
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    VATabBarViewController *tapViewController = [[VATabBarViewController alloc] init];
    self.window.rootViewController = tapViewController;
    [self.window makeKeyAndVisible];
    
    // status bar color
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    view.backgroundColor = RGBCOLOR(238, 238, 238, 1);
    [self.window.rootViewController.view addSubview:view];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UINavigationController *navigationVC = [tapViewController.viewControllers objectAtIndex:0];
    VAWebViewController *webViewController = (VAWebViewController *) navigationVC.topViewController;
    webViewController.needNavigateToEvaluatePage = YES;
    webViewController.evaluatePage = [NSString stringWithFormat:@"%@/vproject/evaluation.html?currentSessionSn=%@", [kUserDefaults objectForKey:kH5ServerURL], sessionSn];
}

- (void)navigateToLaunch2Page
{
    NSString *firstTimeOpenedFlag = [[NSUserDefaults standardUserDefaults] objectForKey:kOpenedFirstTime];
    if (firstTimeOpenedFlag == nil || [@"" isEqualToString:firstTimeOpenedFlag]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kOpenedFirstTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        VAFirstOpenViewController *firstOpenViewController = [[VAFirstOpenViewController alloc] init];
        self.window.rootViewController = firstOpenViewController;
    } else {
        VALaunch2ViewController *launch2ViewController = [[VALaunch2ViewController alloc] init];
        self.window.rootViewController = launch2ViewController;
    }
    
    [self.window makeKeyAndVisible];
}

#pragma mark - WXApiDelegate
-(void) onResp:(BaseResp*)resp
{
    NSLog(@"%@", resp);
}

#pragma mark - remote notification
/**
 *  取得推播通知token
 */
//- (void)procRegisterRemoteNotification {
//    
//    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"tokenForRemotePushNotificaion"];
//    
//    if (!token) {
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//            [[UIApplication sharedApplication] registerForRemoteNotifications];
//        } else {
//            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
//        }
//    }
//    
//}

/**
 *  收到推播通知token後，先儲存在local端
 *
 *  @param application application description
 *  @param deviceToken deviceToken description
 */
//- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
//    
//    // 將DeviceToken做處理, 取得推播的DeviceToken
//    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
//    token = [[[token stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
//    
//    TMNNetworkLogicController *apiManager = [TMNNetworkLogicManager sharedInstace];
//    
//    NSLog(@"device id= %@, token= %@", [apiManager currentUser].deviceID, token);
//    
//    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"tokenForRemotePushNotificaion"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    if (token) {
//        // 已經有推播token，註冊app到server
//        [apiManager registerPushNotificaionWithToken:token isValid:YES successBlock:^(NSDictionary *responseDic) {
//            
//            //NSLog(@"----success didRegisterForRemoteNotificationsWithDeviceToken, responseDic=%@", responseDic);
//            
//            // 註冊所有channel到server
//            [apiManager registerAllChannelPushNotificaionWithToken:token isValid:YES successBlock:^(NSDictionary *responseDic) {
//                //NSLog(@"----success registerAllChannelPushNotificaionWithToken, responseDic=%@", responseDic);
//                
//                // 成功註冊所有channel，寫入local設定
////                [TMNUserDefaultsUtil saveIsTurnOn:YES forReminderType:Reminder5hr];
////                [TMNUserDefaultsUtil saveIsTurnOn:YES forReminderType:Reminder1hr];
////                [TMNUserDefaultsUtil saveIsTurnOn:YES forReminderType:Reminder15min];
////                [TMNUserDefaultsUtil saveIsTurnOn:YES forReminderType:Reminder65min];
//                
//                // local寫入成功註冊推播server成功的flag
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[kIsSave2PushServer copy]];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                
//            } failedBlock:^(NSError *error, id responseObject) {
//                NSLog(@"====fail registerAllChannelPushNotificaionWithToken, responseDic=%@", responseObject);
//            }];
//            
//        } failedBlock:^(NSError *error, id responseObject) {
//            NSLog(@"====fail didRegisterForRemoteNotificationsWithDeviceToken, responseDic=%@", responseObject);
//        }];
//    }
//}
//
//- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
//    NSLog(@"--AppDelegate.application:didFailToRegisterForRemoteNotificationsWithError:, error=%@", error);
//}
//
//- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
//    
//    
//}
//- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification *)notification{
//    
//    NSLog(@"notificationSetting=%@",notification);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"JudgeCheckIn" object:self];
//}

- (void)initNetwork
{
    TMNNetworkLogicController *apiManager = [TMNNetworkLogicManager sharedInstace];
    [apiManager getTrackStarterWithBrandId:TMNBrandID_VIPABC
                                   version:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
                              successBlock:^(NSDictionary *responseDic) {
                                  [self performLogin];
                              }
                               failedBlock:^(NSError *error, id responseObject) {
                                   [self performLogin];
                               }];

}

#pragma mark - Login
- (void)performLogin
{
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:@"account"];
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    
    BOOL canLogin = (account && password);
    
    if (canLogin) {
        [[TMNNetworkLogicManager sharedInstace] loginWithAccount:account
                            password:password
                             brandId:TMNBrandID_VIPABC
                        successBlock:^(id object) {
                            NSLog(@"[login] good:%@", object);
                        } failedBlock:^(NSError *error, id responseObject) {
                            [SVProgressHUD dismiss];
                            
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUserKey];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            NSLog(@"[login] fail error:%@, response:%@", error, responseObject);
                        }];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUserKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self fetchConfigure];
}

#pragma mark - Fetch Configure
- (void)fetchConfigure
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    [VANetworkInterface fetchConfigureWithVersion:[[mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"] appName:[[mainBundle infoDictionary] objectForKey:@"CFBundleName"] platForm:@"ios" deviceType:@"iphone" language:@"zh-cn" successBlock:^(id responseObject) {
        NSError *error = nil;
        
        NSString *jsonResult = [responseObject objectForKey:@"JsonResult"];
        NSData *resultData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonResultDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        NSArray *urls = [[jsonResultDic objectForKey:@"Host"] componentsSeparatedByString:@","];
        
        if (urls.count > 0)
            [kUserDefaults setObject:[urls objectAtIndex:0] forKey:kApiServerURL];
        
        if (urls.count > 1)
            [kUserDefaults setObject:[urls objectAtIndex:1] forKey:kH5ServerURL];
        
        NSArray *messages = [jsonResultDic objectForKey:@"Messages"];
        
        NSMutableDictionary *messagesDic = [NSMutableDictionary dictionary];
        
        for (NSDictionary *dic in messages) {
            [messagesDic setObject:[dic objectForKey:@"Content"] forKey:[dic objectForKey:@"Code"]];
        }
        
        [kUserDefaults setObject:messagesDic forKey:kCommonMessagesKey];
        [kUserDefaults setObject:jsonResultDic forKey:kConfigureInfo];
        
        NSArray *array = [[jsonResultDic objectForKey:@"DailyWordSentence"] componentsSeparatedByString:@"|"];
        [kUserDefaults setObject:array[0] forKey:kDailyWord];
        [kUserDefaults setObject:array.count > 1 ? array[1] : array[0] forKey:kDailyWordAuthor];
        
        NSString *dailyImageURL = [[[NSUserDefaults standardUserDefaults] objectForKey:kConfigureInfo] objectForKey:@"DailyWordImageUrl"];
        if (dailyImageURL != nil && ![@"" isEqualToString:dailyImageURL]) {
            NSString *documentPath = [[NSString stringWithFormat:@"%@", NSTemporaryDirectory()] stringByAppendingPathComponent:kDailyImageName];
            NSData *dailyData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dailyImageURL]];
//            [dailyData writeToFile:documentPath atomically:YES];
            [dailyData writeToFile:documentPath options:NSDataWritingFileProtectionMask error:nil];
        }
        
        [kUserDefaults synchronize];
        
        [self navigateToLaunch2Page];

    } failedBlock:^(NSError *error, id responseObject) {
        [self navigateToLaunch2Page];

    }];
}
@end
