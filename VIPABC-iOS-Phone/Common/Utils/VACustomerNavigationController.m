//
//  VACustomerViewController.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/2/1.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VACustomerNavigationController.h"

@interface VACustomerNavigationController ()

@end

@implementation VACustomerNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allowLandscape = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotate
{
    if (self.onlyLandscape)
        return NO;
    
    if (self.allowLandscape)
        return YES;
    
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.onlyLandscape)
        return UIInterfaceOrientationLandscapeLeft;
    
    if (self.allowLandscape)
        return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.onlyLandscape)
        return UIInterfaceOrientationMaskLandscapeLeft;
    
    if (self.allowLandscape)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
