
//
//  VAFirstOpenViewController.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/2/23.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAFirstOpenViewController.h"
#import "AppDelegate.h"

@interface VAFirstOpenViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation VAFirstOpenViewController

@synthesize pageControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    NSString *firstImageName = iPhone5 ? @"VAFirstOpen_1_5" : @"VAFirstOpen_1_6";
    NSString *secondImageName = iPhone5 ? @"VAFirstOpen_2_5" : @"VAFirstOpen_2_6";
    NSString *thirdImageName = iPhone5 ? @"VAFirstOpen_3_5" : @"VAFirstOpen_3_6";
    
    UIView *firstView = [self generateViewWithImageName:firstImageName];
    UIView *secondView = [self generateViewWithImageName:secondImageName];
    UIView *thirdView = [self generateViewWithImageName:thirdImageName];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.contentSize = CGSizeMake(kScreenWidth * 3, kScreenHeight);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    
    [scrollView addSubview:firstView];
    [scrollView addSubview:secondView];
    [scrollView addSubview:thirdView];
    
    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(scrollView);
        make.height.equalTo(scrollView);
        make.center.equalTo(scrollView);
    }];
    
    [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(scrollView);
        make.height.equalTo(scrollView);
        make.centerY.equalTo(scrollView);
        make.centerX.equalTo(scrollView).offset(kScreenWidth);
    }];
    
    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(scrollView);
        make.height.equalTo(scrollView);
        make.centerY.equalTo(scrollView);
        make.centerX.equalTo(scrollView).offset(kScreenWidth * 2);
    }];
    
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    self.pageControl = [[UIPageControl alloc] init];
    
    pageControl.numberOfPages = 3;
    pageControl.pageIndicatorTintColor = RGBCOLOR(184, 186, 187, 1);
    pageControl.currentPageIndicatorTintColor = RGBCOLOR(241, 51, 60, 1);
    pageControl.defersCurrentPageDisplay = YES;
    
    [self.view addSubview:pageControl];
    
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(20));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20);
    }];
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setTitle:@"跳 过" forState:UIControlStateNormal];
    skipButton.titleLabel.font = DEFAULT_FONT(13);
    skipButton.backgroundColor = RGBCOLOR(255, 255, 255, 0.25);
    skipButton.layer.cornerRadius = 9;
    [skipButton addTarget:self action:@selector(skipCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    
    [firstView addSubview:skipButton];
    [skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(20));
        make.width.equalTo(@(47));
        make.top.equalTo(firstView).offset(15);
        make.right.equalTo(firstView).offset(-15);
        
    }];
    
    UIButton *skip2Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [skip2Button setTitle:@"跳 过" forState:UIControlStateNormal];
    skip2Button.titleLabel.font = DEFAULT_FONT(13);
    skip2Button.backgroundColor = RGBCOLOR(255, 255, 255, 0.25);
    skip2Button.layer.cornerRadius = 9;
    [skip2Button addTarget:self action:@selector(skipCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    
    [secondView addSubview:skip2Button];
    [skip2Button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(20));
        make.width.equalTo(@(47));
        make.top.equalTo(secondView).offset(15);
        make.right.equalTo(secondView).offset(-15);
    }];
    
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [enterButton setTitle:@"马 上 体 验" forState:UIControlStateNormal];
    enterButton.titleLabel.font = DEFAULT_FONT(16);
    enterButton.backgroundColor = RGBCOLOR(241, 51, 60, 1);//RGBCOLOR(247, 76, 76, 1);
    enterButton.layer.cornerRadius = 20;
    [enterButton addTarget:self action:@selector(skipCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    
    [thirdView addSubview:enterButton];
    [enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(40));
        make.width.equalTo(@(150));
        make.centerX.equalTo(thirdView);
        make.bottom.equalTo(thirdView).offset(iPhone5 ? -55 : -70);
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)generateViewWithImageName:(NSString *)imageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    
    UIView *resultView = [UIView new];
    resultView.backgroundColor = [UIColor clearColor];
    [resultView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(resultView);
        make.height.equalTo(resultView);
        make.center.equalTo(resultView);
    }];
    
    return resultView;
}

- (void)skipCurrentPage
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate navigateToLaunch2Page];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float x = scrollView.contentOffset.x;
    
    if (x < 0)
        [scrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, kScreenHeight) animated:NO];
    else if (x > kScreenWidth * 2)
        [scrollView scrollRectToVisible:CGRectMake(kScreenWidth * 2, 0, kScreenWidth, kScreenHeight) animated:NO];
    
    if (x > (scrollView.frame.size.width + scrollView.frame.size.width / 2))
        self.pageControl.currentPage = 2;
    else if (x < scrollView.frame.size.width / 2)
        self.pageControl.currentPage = 0;
    else
        self.pageControl.currentPage = 1;
}

@end
