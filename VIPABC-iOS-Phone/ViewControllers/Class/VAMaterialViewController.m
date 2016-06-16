//
//  VAMaterialViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 16/1/13.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAMaterialViewController.h"
#import "TMNNetworkLogicController.h"
#import "TMNNetworkLogicManager.h"
#import "UIImageView+WebCache.h"
#import "KKScrollView.h"
#import "VACustomerNavigationController.h"
#import "VATool.h"
#import "VAWordPreviewViewController.h"

@interface VAMaterialViewController ()

@property (nonatomic, strong) KKScrollView *scrollView;
@property (nonatomic, strong) UIView *lastSelectedView;
@property (nonatomic, strong) NSMutableArray *smallImageViews;
@property (nonatomic, strong) UIScrollView *smallScrollView;
@property (nonatomic, assign) float imageScale;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UILabel *currentPageLabel;

@end

@implementation VAMaterialViewController

@synthesize classinfo, scrollView, smallScrollView, prevButton, nextButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    VACustomerNavigationController *customerNavigationVC = (VACustomerNavigationController *) self.navigationController;
    customerNavigationVC.allowLandscape = YES;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.hidden = YES;
    [self.backButton setImage:[UIImage imageNamed:@"VABack"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"VABack"] forState:UIControlStateHighlighted];
    [self.backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(10);
    }];
    
    self.title = @"教材预览";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"VABack"] forState:UIControlStateNormal];
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    backButton.frame = CGRectMake(0, 0, 25, 25);
    [backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    UIButton *wordPreviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [wordPreviewButton setTitle:@"单词" forState:UIControlStateNormal];
    wordPreviewButton.titleLabel.textColor = [UIColor redColor];
    wordPreviewButton.titleLabel.font = DEFAULT_FONT(16);
    wordPreviewButton.frame = CGRectMake(0, 0, 50, 25);
    [wordPreviewButton addTarget:self action:@selector(navigateToWordPreview) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:wordPreviewButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
    
    self.smallImageViews = [NSMutableArray array];
    
    [SVProgressHUD show];
    TMNNetworkLogicController *apiManager = [TMNNetworkLogicManager sharedInstace];
    
    NSString *materialSn = classinfo.materialSn;
    
    if (!materialSn)
        materialSn = @"";
    
    [apiManager getMaterialFileWithPath:materialSn successBlock:^(id responseObject){
    
        [self initMaterialView:responseObject];
        
        [SVProgressHUD dismiss];
        
    }  failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
    
    // default image size 701 526
    self.imageScale = 701.0 / 526.0f;
}

- (void)initMaterialView:(NSDictionary *)dic
{
    int imageNumber = [[dic objectForKey:@"materialNum"] intValue];
    NSArray *materialUrlarray = [dic objectForKey:@"materialUrl"];
        
    scrollView = [[KKScrollView alloc] initWithFrame:CGRectMake(0, 50, kScreenWidth, iPhone5 ? 240.0 : 282.0) images:nil autoCycle:NO defaultImageName:nil];
    scrollView.imagesArray = [materialUrlarray mutableCopy];
    [scrollView refreshScrollView];
    [self.view addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(50);
        make.height.equalTo(@(iPhone5 ? 240.0 : 282.0));
        make.width.equalTo(@(kScreenWidth));
    }];
    
    self.currentPageLabel = [VATool getLabelWithTextString:[NSString stringWithFormat:@"1/%lu", (unsigned long)materialUrlarray.count] fontSize:14 textColor:[UIColor blackColor] sapce:0 bold:YES];
    [self.view addSubview:self.currentPageLabel];
    
    [self.currentPageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(scrollView.bottom).offset(15);
    }];
    
    float imageWidth = kScreenWidth / 4;
    float imageHeight = iPhone5 ? 50 : 60;
    smallScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, iPhone5 ? 350 : 420, kScreenWidth, imageHeight)];
    smallScrollView.showsHorizontalScrollIndicator = NO;
    smallScrollView.showsVerticalScrollIndicator = NO;
    smallScrollView.backgroundColor = [UIColor clearColor];
    smallScrollView.scrollEnabled = YES;
    
    for (int i = 0; i < imageNumber; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * imageWidth, 0, imageWidth, imageHeight)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[materialUrlarray objectAtIndex:i]] placeholderImage:nil];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        [imageView addGestureRecognizer:gesture];
        
        [smallScrollView addSubview:imageView];
        
        [_smallImageViews addObject:imageView];
    }
    
    smallScrollView.contentSize = CGSizeMake(imageWidth * imageNumber, 0);
    
    [self.view addSubview:smallScrollView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:VANotificationScrollPageValueChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewPageChanaged:) name:VANotificationScrollPageValueChanged object:nil];
    
    [self scrollViewPageChanaged:nil];
    
    self.prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevButton setImage:[UIImage imageNamed:@"SessionRoomMaterialPrev"] forState:UIControlStateNormal];
    [prevButton addTarget:self action:@selector(prevButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    prevButton.hidden = YES;
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"SessionRoomMaterialNext"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    nextButton.hidden = YES;
    
    [self.view addSubview:prevButton];
    [self.view addSubview:nextButton];
    
    [prevButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).offset(20);
    }];
    
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.right.equalTo(self.view).offset(-20);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewController
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigateToWordPreview
{
    VAWordPreviewViewController *wordPreviewVC = [[VAWordPreviewViewController alloc] init];
    wordPreviewVC.classinfo = self.classinfo;
    [self.navigationController pushViewController:wordPreviewVC animated:YES];
}

- (void)prevButtonTapped
{
    if (scrollView.pageControl.currentPage == 0)
        [scrollView refreshScrollViewImages:scrollView.imagesArray.count - 1];
    else
        [scrollView refreshScrollViewImages:scrollView.pageControl.currentPage - 1];
}

- (void)nextButtonTapped
{
    if (scrollView.pageControl.currentPage == scrollView.imagesArray.count - 1)
        [scrollView refreshScrollViewImages:0];
    else
        [scrollView refreshScrollViewImages:scrollView.pageControl.currentPage + 1];
}

- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer
{
    [self didUnSelectedView:_lastSelectedView];
    
    UIView *selectedView=(UIView *)[recognizer view];
    _lastSelectedView = selectedView;
    NSInteger menuId = selectedView.tag;
    
    [self didSelectedView:selectedView];
    
    [scrollView refreshScrollViewImages:menuId];
}

- (void)didSelectedView:(UIView *)selectedView
{
    selectedView.layer.borderWidth = 2;
    selectedView.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (void)didUnSelectedView:(UIView *)unSelectedView
{
    unSelectedView.layer.borderWidth = 0;
}

#pragma mark -
- (void)scrollViewPageChanaged:(NSNotification *)notification
{
    for (UIView *view in _smallImageViews) {
        NSInteger currendIndex = scrollView.pageControl.currentPage;
        
        if (view.tag == currendIndex) {
            [self didUnSelectedView:_lastSelectedView];
            
            _lastSelectedView = view;
            
            [self didSelectedView:view];
            
            CGPoint point = smallScrollView.contentOffset;
            
            float selectedViewWidth = (view.tag + 1) * (kScreenWidth / 4);
            
            if ((point.x + kScreenWidth) < selectedViewWidth)
                [smallScrollView setContentOffset:CGPointMake(selectedViewWidth - kScreenWidth, smallScrollView.contentOffset.y)];
            else if (point.x > selectedViewWidth)
                [smallScrollView setContentOffset:CGPointMake(selectedViewWidth - kScreenWidth / 4, smallScrollView.contentOffset.y)];
        }
    }
    
    self.currentPageLabel.text = [NSString stringWithFormat:@"%ld/%lu", (long)(scrollView.pageControl.currentPage + 1), (unsigned long)scrollView.imagesArray.count];
}

#pragma mark - Autorotate
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait ||
        self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.view).offset(50);
            make.height.equalTo(@(iPhone5 ? 240.0 : 282.0));
            make.width.equalTo(@(kScreenWidth));
        }];
        
        self.navigationController.navigationBarHidden = NO;
        self.backButton.hidden = YES;
        prevButton.hidden = YES;
        nextButton.hidden = YES;
        
        self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
        
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.currentPageLabel.hidden = NO;
    }
    else {
        [scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(@((self.view.bounds.size.width - scrollView.bounds.size.width) / 2.0));
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view.top);
            make.height.equalTo(@(kScreenHeight));
            make.width.equalTo(@(kScreenHeight * self.imageScale));
        }];
        
        self.navigationController.navigationBarHidden = YES;
        self.backButton.hidden = NO;
        prevButton.hidden = NO;
        nextButton.hidden = NO;
        
        self.view.backgroundColor = [UIColor lightGrayColor];
        [UIApplication sharedApplication].statusBarHidden = YES;
        self.currentPageLabel.hidden = YES;
    }
    
    [self.scrollView updateFrame];
    [self.scrollView refreshScrollViewImages:scrollView.pageControl.currentPage];
}

@end
