//
//  HomeViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/26.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VAHomeViewController.h"
#import "VALoginViewController.h"
#import "VAWebViewController.h"
#import "TMNNetworkLogicController.h"
#import "TMNNetworkLogicManager.h"

@interface VAHomeViewController ()

@end

@implementation VAHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (IBAction)navigateToLoginViewController:(id)sender {
    VALoginViewController *loginVC = [[VALoginViewController alloc] init];
    [self presentViewController:loginVC animated:YES completion:^{}];
}
- (IBAction)naviagteToWebViewController:(id)sender {
    VAWebViewController *webViewController = [[VAWebViewController alloc] init];
    [self.navigationController pushViewController:webViewController animated:YES];
    
}
@end
