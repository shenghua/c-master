//
//  BaseViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/26.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VABaseViewController.h"

@interface VABaseViewController ()

@end

@implementation VABaseViewController

- (void)loadView
{
    [super loadView];
    
//    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置Navigation bar 颜色
    self.navigationController.navigationBar.backgroundColor = RGBCOLOR(252, 252, 252, 1);
    self.navigationController.navigationBar.translucent = NO;
    
    // 隐藏阴影线
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma makr - Autorotate
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
@end
