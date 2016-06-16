//
//  VALaunchViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 16/1/6.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VALaunch2ViewController.h"
#import "VATool.h"
#import "AppDelegate.h"

@interface VALaunch2ViewController ()

@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, assign) int secondsCountDown;

@end

@implementation VALaunch2ViewController

- (void)loadView
{
    [super loadView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    NSString *imageName = @"";
    
    if (iPhone4)
        imageName = @"VALaunch2Background_4";
    else if (iPhone5)
        imageName = @"VALaunch2Background_5";
    else if (iPhone6)
        imageName = @"VALaunch2Background_6";
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = [VATool fetchDailyImage];
    
    [self.view addSubview:bgImageView];
    
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"MMM dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    UILabel *dateLabel = [VATool getLabelWithTextString:dateString fontSize:16 textColor:[UIColor whiteColor] sapce:0 bold:YES];
    [self.view addSubview:dateLabel];
    
    UIView *leftLineView = [[UIView alloc] init];
    leftLineView.backgroundColor = RGBCOLOR(151, 151, 151, 1);
    [self.view addSubview:leftLineView];
    
    UIView *rightLineView = [[UIView alloc] init];
    rightLineView.backgroundColor = RGBCOLOR(151, 151, 151, 1);
    [self.view addSubview:rightLineView];
    
    UILabel *detailLabel = [VATool getLabelWithTextString:[NSString stringWithFormat:@"\"%@\"", [VATool fetchDailyWord]] fontSize:35 textColor:[UIColor whiteColor] sapce:5 bold:YES];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:detailLabel];

    UILabel *authorLabel = [VATool getLabelWithTextString:[NSString stringWithFormat:@"—— %@", [VATool fetchDailyWordAuthor]] fontSize:18 textColor:[UIColor whiteColor] sapce:0 bold:YES];
//    authorLabel.hidden = YES;
    [self.view addSubview:authorLabel];
    
    UILabel *tipsLabel = [VATool getLabelWithTextString:@"每日一句" fontSize:12 textColor:[UIColor whiteColor] sapce:0 bold:NO];
    tipsLabel.backgroundColor = RGBCOLOR(120, 120, 120, 1);
    tipsLabel.layer.cornerRadius = 8;
    tipsLabel.layer.masksToBounds = YES;
    [self.view addSubview:tipsLabel];
    
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.view.top).offset(24);
        make.bottom.equalTo(self.view.bottom).offset(-40);
    }];
    
    [leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(dateLabel);
        make.height.equalTo(@(1));
        make.left.equalTo(self.view.left).offset(25);
        make.right.equalTo(dateLabel.left).offset(-14.5);
    }];
    
    [rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(dateLabel);
        make.height.equalTo(@(1));
        make.left.equalTo(dateLabel.right).offset(14.5);
        make.right.equalTo(self.view.right).offset(-25);
    }];
    
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(28);
        make.top.equalTo(self.view.top).offset(iPhone5 ? 80 + 24 : 120 + 24);
        make.width.equalTo(@(270));
    }];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detailLabel.bottom).offset(30);
        make.right.equalTo(self.view).offset(-30);
    }];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(detailLabel);
        make.bottom.equalTo(detailLabel.top).offset(-20);
        make.width.equalTo(@(65));
        make.height.equalTo(@(17));
    }];
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setTitle:@"跳 过" forState:UIControlStateNormal];
    skipButton.titleLabel.font = DEFAULT_FONT(13);
    skipButton.backgroundColor = RGBCOLOR(255, 255, 255, 0.25);
    skipButton.layer.cornerRadius = 9;
    [skipButton addTarget:self action:@selector(skipCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:skipButton];
    [skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(20));
        make.width.equalTo(@(47));
        make.top.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        
    }];
    
    self.secondsCountDown = 4;
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.countDownTimer invalidate];
}

- (void)timerFire
{
    self.secondsCountDown--;
    
    if (self.secondsCountDown<=0) {
        [self.countDownTimer invalidate];
        
        [self skipCurrentPage];
    }
}

- (void)skipCurrentPage
{
    [self.countDownTimer invalidate];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate navigateToTabBarPage];
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
