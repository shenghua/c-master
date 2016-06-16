//
//  VATapViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/26.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VATabBarViewController.h"
#import "TMNNetworkLogicController.h"
#import "TMNNetworkLogicManager.h"
#import "VAClassPreparationViewController.h"
#import "VAWebViewController.h"
#import "VALoginViewController.h"
#import "TMContract.h"
#import "AppDelegate.h"
#import "VATool.h"
#import "VACustomerNavigationController.h"

@interface VATabBarViewController ()

@property (nonatomic, strong) TMNNetworkLogicController *apiManager;
@property (nonatomic, assign) BOOL rightVisitClassPage;
@property (nonatomic, assign) BOOL hasContractInfo;
@property (nonatomic, assign) BOOL needShowCallButton;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) NSString *h5ServerURL;
@property (nonatomic, assign) BOOL requestFinished;

@end

@implementation VATabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.viewControllers = [self initialTabBarViewControllerItems];
    
    // 设置字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:
                                [NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor],NSForegroundColorAttributeName, nil]
                            forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:
                                [NSDictionary dictionaryWithObjectsAndKeys:RGBCOLOR(247, 76, 76, 1),NSForegroundColorAttributeName, nil]
                            forState:UIControlStateSelected];
    
    // 更改tabbar背景颜色
    UIView *tabBarBackgroundView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    tabBarBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:tabBarBackgroundView atIndex:0];
    self.tabBar.opaque = YES;
    
    // 隐藏阴影线
    [self.tabBar setClipsToBounds:YES];
    
    self.apiManager = [TMNNetworkLogicManager sharedInstace];
    
    self.rightVisitClassPage = YES;
    
    self.h5ServerURL = [kUserDefaults objectForKey:kH5ServerURL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.requestFinished = YES;
    if (![self isLogOut]) {
        [self hasRightVisitClassPage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)initialTabBarViewControllerItems
{
    NSMutableArray *tabBarViewControllers = [NSMutableArray array];
    
    NSArray *tabBarItems = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"VATabBarItems" ofType:@"plist"]];
    
    for (NSArray *item in tabBarItems) {
        UIImage *tabBarItemImage = [UIImage imageNamed:item[1]];
        UIImage *tabBarItemSelectedImage = [UIImage imageNamed:item[2]];
        tabBarItemImage = [tabBarItemImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItemSelectedImage = [tabBarItemSelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        Class class = NSClassFromString(item[0]);
        UIViewController *viewController = [[class alloc] init];
        viewController.tabBarItem.image = tabBarItemImage;
        viewController.tabBarItem.selectedImage = tabBarItemSelectedImage;
        viewController.tabBarItem.title = item[3];
        viewController.title = item[3];
        
        if ([viewController isKindOfClass:VAWebViewController.class]) {
            VAWebViewController *webVC = (VAWebViewController *) viewController;
            webVC.htmlPath = [NSString stringWithFormat:@"%@%@", [kUserDefaults objectForKey:kH5ServerURL], item[4]];
        }
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.navigationBarHidden = YES;
        [tabBarViewControllers addObject:navigationController];
    }
    
    return tabBarViewControllers;
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 0) {
        [VATool setStatusBarWithColor:RGBCOLOR(238, 238, 238, 1) style:UIStatusBarStyleDefault];
    }
    else {
        [VATool setStatusBarWithColor:RGBCOLOR(247, 76, 76, 1) style:UIStatusBarStyleLightContent];
        
//        if (tabBarController.selectedIndex == 1) {
//            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kShowClassPreparationPage];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    [SVProgressHUD show];
    if (!self.requestFinished) {
        [SVProgressHUD dismiss];
        return NO;
    }
    
    [SVProgressHUD dismiss];
    UINavigationController *selectedViewController = (UINavigationController *)viewController;
    VAWebViewController *webViewController = (VAWebViewController *)selectedViewController.topViewController;
    
    if (self.hasContractInfo)
        [kUserDefaults setObject:@"4006-30-30-22" forKey:kServiceTelphone];
    else
        [kUserDefaults setObject:@"4006-30-30-30" forKey:kServiceTelphone];
    [kUserDefaults synchronize];
    
    // 访问上课、个人中心、未登录的情况
    if (![[NSString stringWithFormat:@"%@/vproject/demonstrationClass.html", _h5ServerURL] isEqualToString:webViewController.htmlPath] && [self isLogOut]) {
        [self navigateToLogin];
        return NO;
    }
    // 判断是否能访问上课页
    else if ([[NSString stringWithFormat:@"%@/lisener/index.html", _h5ServerURL] isEqualToString:webViewController.htmlPath]) {
        
        if (!self.rightVisitClassPage) {
//            [SVProgressHUD showErrorWithStatus:self.errorMessage];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:self.errorMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:self.needShowCallButton ? @"立即拨打" : nil, nil];
            [alertView show];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [VATool sendCall:[VATool fetchServiceTelphone] withParentView:self.view];
}

#pragma mark - Autorotate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - User is logout
- (BOOL)isLogOut
{
    BOOL result = NO;
    
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    if (!account || !password)
        result = YES;
    
    return result;
}

- (void)navigateToLogin
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    VALoginViewController *loginViewController = [[VALoginViewController alloc] init];
    VACustomerNavigationController *navigationVC = [[VACustomerNavigationController alloc] initWithRootViewController:loginViewController];
    
    [self presentViewController:navigationVC animated:YES completion:nil];
}

#pragma makr - Whether has right access to class page
- (void)hasRightVisitClassPage
{
    
    self.rightVisitClassPage = YES;
    self.hasContractInfo = YES;
    self.needShowCallButton = NO;
    
    TMUser *user = [self.apiManager currentUser];
    
    // 无合约
//    if ([user.contractId isEqualToString:@"0"] || user.contractId == nil) {
//        self.errorMessage = @"您尚未购买课程，如需购买请联繫客服人员。";
//        self.rightVisitClassPage = NO;
//        return;
//    }
    // 未做过等级测试
    if (user.level == 0) {
        self.errorMessage = @"你是高手还是新手，先到官网做个语言程度分析吧！";
        self.rightVisitClassPage = NO;
//        return;
    }
    
    self.requestFinished = NO;
    [SVProgressHUD show];
    
    // 获取合约咨询
    [self.apiManager getContractInfoWithSuccessBlock:^(NSArray *responseArray) {
        [SVProgressHUD dismiss];
        self.requestFinished = YES;
        if (responseArray.count > 0) {
            for (TMContract *contract in responseArray) {
                if (!contract.isInService) {
                    NSDate *date = [NSDate date];
                    
                    NSTimeInterval timeNow = [date timeIntervalSince1970];
                    
                    if (timeNow < contract.serviceStartDate / 1000) {
                        self.errorMessage = @"你的课程还未开始哦，请耐心等待~";
//                        self.rightVisitClassPage = NO;
                        self.hasContractInfo = NO;
                    }
                    else {
                        self.errorMessage = @"你尚未购买课程，立即联系顾问订购吧！";
//                        self.rightVisitClassPage = NO;
                        self.needShowCallButton = YES;
                        self.hasContractInfo = NO;
                    }
                }
                else {
                    self.hasContractInfo = YES;
                    if (self.rightVisitClassPage)
//                        self.rightVisitClassPage = YES;
                        self.errorMessage = @"";
                    break;
                }
            }
        }else {
            self.errorMessage = @"你尚未购买课程，立即联系顾问订购吧！";
//            self.rightVisitClassPage = NO;
            self.needShowCallButton = YES;
            self.hasContractInfo = NO;
        }
        
        if (self.rightVisitClassPage)
            self.rightVisitClassPage = self.hasContractInfo;
        
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
}

@end
