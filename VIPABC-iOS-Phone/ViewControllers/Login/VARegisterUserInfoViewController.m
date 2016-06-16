//
//  VARegisterUserInfoViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/27.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VARegisterUserInfoViewController.h"
#import "VAUserModel.h"
#import "TMNNetworkLogicManager.h"
#import "VARegisterViewController.h"
#import "AppDelegate.h"
#import "VARegisterPhoneVerticalViewController.h"
#import "VATool.h"

@interface VARegisterUserInfoViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userEmailTextField;
@property (nonatomic, strong) UITextField *userNameTextField;

@property (nonatomic, strong) UIButton *nextButton;


@end

@implementation VARegisterUserInfoViewController

@synthesize userEmailTextField, userNameTextField, nextButton;

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"VALoginBack"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [closeButton addTarget:self action:@selector(backToParent) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    self.title = @"注册";
    
//    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
//    [registerButton setTitle:@"注册" forState:UIControlStateHighlighted];
//    [registerButton sizeToFit];
//    [registerButton addTarget:self action:@selector(navigateToRegisterPage) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:registerButton];
    
    self.userEmailTextField = [[UITextField alloc] init];
//    [userEmailTextField becomeFirstResponder];
    userEmailTextField.font = DEFAULT_FONT(16.0);
    userEmailTextField.tintColor = [UIColor darkGrayColor];
    userEmailTextField.textColor = [UIColor blackColor];
    userEmailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userEmailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"邮 箱" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    userEmailTextField.returnKeyType = UIReturnKeyGo;
    userEmailTextField.delegate = self;
    [self.view addSubview:userEmailTextField];
    
    self.userNameTextField = [[UITextField alloc] init];
    userNameTextField.font = DEFAULT_FONT(16.0);
    userNameTextField.tintColor = [UIColor darkGrayColor];
    userNameTextField.textColor = [UIColor blackColor];
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"用户名" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userNameTextField.keyboardType = UIKeyboardTypeDefault;
    userNameTextField.delegate = self;
    userNameTextField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:userNameTextField];
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView2];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"下 一 步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.backgroundColor = RGBCOLOR(247, 76, 76, 1);
    nextButton.layer.cornerRadius = 8;
    [self.view addSubview:nextButton];
    
    UILabel *tipsLabel = [VATool getLabelWithTextString:@"已 经 是 会 员？" fontSize:14 textColor:[UIColor lightGrayColor] sapce:0 bold:NO];
//    tipsLabel.backgroundColor = [UIColor redColor];
    [self.view addSubview:tipsLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"登 录" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGBCOLOR(247, 76, 76, 1) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(navigateToLoginPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginLogo"]];
    [self.view addSubview:logoImageView];
    
    UIImageView *emailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginMail"]];
    [self.view addSubview:emailImageView];
    
    UIImageView *nameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginPersonal"]];
    [self.view addSubview:nameImageView];
    
    [emailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userEmailTextField);
        make.left.equalTo(self.view).offset(15);
    }];
    
    [nameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userNameTextField);
        make.centerX.equalTo(emailImageView);
    }];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(30);
    }];
    
    [userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@((iPhone5 ? 140.0 : 150.0) * 2));
        make.height.equalTo(@(30.0));
        make.left.equalTo(nameImageView.right).offset(8);
        make.top.equalTo(self.view).offset(120.0);
    }];
    
    [userEmailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(userNameTextField);
        make.height.equalTo(userNameTextField);
        make.centerX.equalTo(userNameTextField);
        make.top.equalTo(userNameTextField.bottom).offset(20);
    }];
    
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(1));
        make.left.equalTo(self.view);
        make.top.equalTo(userNameTextField.bottom).offset(5);
    }];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView1);
        make.height.equalTo(lineView1);
        make.left.equalTo(lineView1);
        make.top.equalTo(userEmailTextField.bottom).offset(5);
    }];
    
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kScreenWidth - 30));
        make.height.equalTo(@(22.5 * 2));
        make.centerX.equalTo(self.view);
        make.top.equalTo(lineView2).offset(40);
    }];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cancelButton);
        make.centerX.equalTo(nextButton).offset(-12);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@(90.0 * 2));
        make.height.equalTo(nextButton);
        make.left.equalTo(tipsLabel.right).offset(2);
        make.top.equalTo(nextButton).offset(50);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UINavigationBar appearance] setBarTintColor:RGBCOLOR(247, 76, 76, 1)];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextButtonTapped
{
    NSString *email = userEmailTextField.text;
    NSString *name = userNameTextField.text;
    
    BOOL isError = NO;
    NSString *errorMessage = @"";
    
    if ([@"" isEqualToString:name]) {
        isError = YES;
        errorMessage = @"请输入用户名！";
    }
    else if ([@"" isEqualToString:email]) {
        isError = YES;
        errorMessage = @"请输入邮箱！";
    }
    else if (![self isValidateEmail:email]) {
        isError = YES;
        errorMessage = @"请输入正确的邮箱！";
    }
    
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    if (isError) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
        return;
    }
    
    VARegisterPhoneVerticalViewController *nextVC = [[VARegisterPhoneVerticalViewController alloc] init];
    nextVC.name = name;
    nextVC.email = email;
    [self.navigationController pushViewController:nextVC animated:YES];

}

- (void)navigateToLoginPage
{
    [self.userEmailTextField resignFirstResponder];
    [self.userNameTextField resignFirstResponder];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)backToParent
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)isValidateEmail:(NSString *)email

{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailPredicate evaluateWithObject:email];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        if (textField == userNameTextField) {
            [userEmailTextField becomeFirstResponder];
            return NO;
        }
        else if (textField == userEmailTextField) {
            [self nextButtonTapped];
            return NO;
        }
    }
    else if ([string isEqualToString:@" "]){
        return NO;
    }
    else if (![string isEqualToString:@""]) {
        if (textField == userNameTextField && (textField.text.length >= 30 || ![self isValidateName:string]))
            return NO;
        else if (textField == userEmailTextField && textField.text.length >= 100)
            return NO;
    }
    
    return YES;
}

// 验证用户名(支持中英文)
- (BOOL)isValidateName:(NSString *)name
{
    NSString *nameRegex = @"^[\u4e00-\u9fa5_a-zA-Z]+$";
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    
    BOOL isValidate = [namePredicate evaluateWithObject:[name lowercaseString]];
    
    if (!isValidate)
        [SVProgressHUD showErrorWithStatus:@"仅可输入中文和英文哦"];
    return isValidate;
}
@end
