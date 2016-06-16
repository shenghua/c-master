//
//  AlertView.m
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/9/8.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "AlertView.h"

NSString * const kINFO_ICON = @"learning_icon_tips";
NSString * const kMSG_ICON = @"sessionroom_icon_send msg";

@interface AlertView()

@property (nonatomic, weak) UIViewController *rootController;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation AlertView

- (instancetype)init {
    
    NSArray *array;
    NSBundle *bundle = [NSBundle bundleForClass:AlertView.class];
    array = [bundle loadNibNamed:NSStringFromClass(AlertView.class)
                           owner:self
                         options:nil];
    self = (AlertView *)array.lastObject;
    if (self) {
        // your statement
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title text:(NSString *)text {
    self = [self init];
    if (self) {
        self.titleImage.image = image;
        self.titleLabel.text = title;
        self.contentLabel.text = text;
    }
    return self;
}

#pragma mark - Visibility
- (void)show {
    
    // Move to center of controller
    CGRect rootFrame = UIScreen.mainScreen.bounds;
    NSLog(@"rootFrame %f, %f, %f, %f", rootFrame.origin.x, rootFrame.origin.y, rootFrame.size.width, rootFrame.size.height);
    CGFloat centerX = rootFrame.size.width / 2 - self.frame.size.width / 2;
    CGFloat centerY = rootFrame.size.height / 2 - self.frame.size.height / 2;
    self.frame = CGRectMake(centerX, centerY, self.frame.size.width, self.frame.size.height);
    NSLog(@"%f, %f, %f, %f", centerX, centerY, self.frame.size.width, self.frame.size.height);
    
    // Setup background
    self.backgroundView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:.5f];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            [window addSubview:self.backgroundView];
            [window addSubview:self];
            break;
        }
    }
}

- (void)showIn:(UIViewController *)controller {
    self.rootController = controller;
    
    // Move to center of controller
    CGRect rootFrame = controller.view.frame;
    CGFloat centerX = rootFrame.size.width / 2 - self.frame.size.width / 2;
    CGFloat centerY = rootFrame.size.height / 2 - self.frame.size.height / 2;
    self.frame = CGRectMake(centerX, centerY, self.frame.size.width, self.frame.size.height);
    
    // Make blur background
    self.backgroundView = [[UIView alloc] initWithFrame:controller.view.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:.5f];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    // Add view controller subviews
    [self.rootController.view addSubview:self.backgroundView];
    [self.rootController.view addSubview:self];
    
}

- (void)dismissFrom:(UIViewController *)controller {
    [self dismissAll];
}

- (void)dismissAll {
    [self.backgroundView removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - UI Action
- (IBAction)leftButtonPressed:(UIButton *)sender {
    if (self.leftButtonAction) self.leftButtonAction(self);
    else [self dismissAll];
}

- (IBAction)rightButtonPressed:(UIButton *)sender {
    if (self.rightButtonAction) self.rightButtonAction(self);
    else [self dismissAll];
}

#pragma mark - Class mehtods
+ (AlertView *)sharedView {
    static dispatch_once_t once;
    
    static AlertView *sharedView;
    dispatch_once(&once, ^{
        sharedView = [[self alloc] init];
    });
    return sharedView;
}

// Load Tips icon
+ (AlertView *)showInfoWithTitle:(NSString *)title text:(NSString *)text {
    
    self.sharedView.titleImage.image = [UIImage imageNamed:kINFO_ICON];
    self.sharedView.titleLabel.text = title;
    self.sharedView.contentLabel.text = text;
    
    [self.sharedView.leftButton.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstAttribute == NSLayoutAttributeWidth) {
            self.sharedView.leftButtonWidthConstraint = obj;
        }
    }];
    
    [self.sharedView.rightButton.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstAttribute == NSLayoutAttributeWidth) {
            self.sharedView.rightButtonWidthConstraint = obj;
        }
    }];
    
    [self.sharedView show];
    
    return self.sharedView;
}

+ (AlertView *)showInfoWithTitle:(NSString *)title
                            text:(NSString *)text
                             in:(UIViewController *)controller {
    self.sharedView.titleImage.image = [UIImage imageNamed:kINFO_ICON];
    self.sharedView.titleLabel.text = title;
    self.sharedView.contentLabel.text = text;
    
    [self.sharedView showIn:controller];
    return self.sharedView;
}

// Load Send Message icon
+ (AlertView *)showMsgWithTitle:(NSString *)title
                           text:(NSString *)text {
    
    self.sharedView.titleImage.image = [UIImage imageNamed:kMSG_ICON];
    self.sharedView.titleLabel.text = title;
    self.sharedView.contentLabel.text = text;
    [self.sharedView show];
    return self.sharedView;
}

+ (AlertView *)showMsgWithTitle:(NSString *)title
                           text:(NSString *)text
                             in:(UIViewController *)controller {
    self.sharedView.titleImage.image = [UIImage imageNamed:kMSG_ICON];
    self.sharedView.titleLabel.text = title;
    self.sharedView.contentLabel.text = text;
    [self.sharedView showIn:controller];
    return self.sharedView;
}

+ (void)dismissAll {
    [self.sharedView removeFromSuperview];
}

@end
