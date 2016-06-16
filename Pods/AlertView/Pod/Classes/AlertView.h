//
//  AlertView.h
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/9/8.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kINFO_ICON;
extern NSString * const kMSG_ICON;

@interface AlertView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (copy, nonatomic) void (^leftButtonAction) (AlertView *alert);
@property (copy, nonatomic) void (^rightButtonAction) (AlertView *alert);

@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *leftButtonWidthConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *rightButtonWidthConstraint;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title text:(NSString *)text;
- (void)show;
- (void)showIn:(UIViewController *)controller;
- (void)dismissFrom:(UIViewController *)controller;
- (void)dismissAll;

// Load Tips icon
+ (AlertView *)showInfoWithTitle:(NSString *)title text:(NSString *)text; // Cover full window
+ (AlertView *)showInfoWithTitle:(NSString *)title text:(NSString *)text in:(UIViewController *)controller;

// Load Send Message icon
+ (AlertView *)showMsgWithTitle:(NSString *)title text:(NSString *)text; // Cover full window
+ (AlertView *)showMsgWithTitle:(NSString *)title text:(NSString *)text in:(UIViewController *)controller;

+ (void)dismissAll;
@end
