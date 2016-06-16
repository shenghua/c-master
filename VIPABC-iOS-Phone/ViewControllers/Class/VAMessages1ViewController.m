//
//  VAMessages1ViewController.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/21.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAMessages1ViewController.h"
#import "VAMessagesView.h"

@interface VAMessages1ViewController ()

@end

@implementation VAMessages1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    VAMessagesView *messagesView = [[VAMessagesView alloc] init];
    [self.view addSubview:messagesView];
    
    [messagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
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

@end
