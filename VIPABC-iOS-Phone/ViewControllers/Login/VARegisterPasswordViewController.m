//
//  VARegisterPasswordViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/27.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VARegisterPasswordViewController.h"
#import "VAUserModel.h"
#import "TMNNetworkLogicManager.h"
#import "VARegisterViewController.h"
#import "AppDelegate.h"
#import "VARegisterPhoneVerticalViewController.h"
#import "VANetworkInterface.h"

@interface VARegisterPasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userPasswordTextField;
@property (nonatomic, strong) UITextField *userRePasswordTextField;

@property (nonatomic, strong) UIButton *registerButton;


@end

@implementation VARegisterPasswordViewController

@synthesize userPasswordTextField, userRePasswordTextField, registerButton;

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
    
    self.userPasswordTextField = [[UITextField alloc] init];
//    [userEmailTextField becomeFirstResponder];
    userPasswordTextField.font = DEFAULT_FONT(16.0);
    userPasswordTextField.tintColor = [UIColor darkGrayColor];
    userPasswordTextField.textColor = [UIColor blackColor];
    userPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密 码（6-14位英文或数字）" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userPasswordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    userPasswordTextField.delegate = self;
    userPasswordTextField.secureTextEntry = YES;
    userPasswordTextField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:userPasswordTextField];
    
    self.userRePasswordTextField = [[UITextField alloc] init];
    userRePasswordTextField.font = DEFAULT_FONT(16.0);
    userRePasswordTextField.tintColor = [UIColor darkGrayColor];
    userRePasswordTextField.textColor = [UIColor blackColor];
    userRePasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userRePasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"确 认 密 码" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userRePasswordTextField.keyboardType = UIKeyboardTypeDefault;
    userRePasswordTextField.delegate = self;
    userRePasswordTextField.secureTextEntry = YES;
    userRePasswordTextField.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:userRePasswordTextField];
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView2];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注 册" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerButton.backgroundColor = RGBCOLOR(247, 76, 76, 1);
    registerButton.layer.cornerRadius = 8;
    [self.view addSubview:registerButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"登 录" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(navigateToLoginPage) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.hidden = YES;
    [self.view addSubview:cancelButton];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginLogo"]];
    [self.view addSubview:logoImageView];
    
    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginPassword"]];
    [self.view addSubview:passwordImageView];
    
    UIImageView *confirmPasswordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginConfirm"]];
    [self.view addSubview:confirmPasswordImageView];
    
    [passwordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userPasswordTextField);
        make.left.equalTo(self.view).offset(15);
    }];
    
    [confirmPasswordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userRePasswordTextField);
        make.centerX.equalTo(passwordImageView);
    }];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(30);
    }];
    
    [userPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@((iPhone5 ? 140.0 : 150.0) * 2));
        make.height.equalTo(@(30.0));
        make.left.equalTo(passwordImageView.right).offset(8);
        make.top.equalTo(self.view).offset(120.0);
    }];
    
    [userRePasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(userPasswordTextField);
        make.height.equalTo(userPasswordTextField);
        make.centerX.equalTo(userPasswordTextField);
        make.top.equalTo(userPasswordTextField.bottom).offset(20);
    }];
    
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(1));
        make.left.equalTo(self.view);
        make.top.equalTo(userPasswordTextField.bottom).offset(5);
    }];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView1);
        make.height.equalTo(lineView1);
        make.left.equalTo(lineView1);
        make.top.equalTo(userRePasswordTextField.bottom).offset(5);
    }];
    
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kScreenWidth - 30));
        make.height.equalTo(@(22.5 * 2));
        make.centerX.equalTo(self.view);
        make.top.equalTo(lineView2).offset(40);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(90.0 * 2));
        make.height.equalTo(registerButton);
        make.centerX.equalTo(registerButton);
        make.top.equalTo(registerButton).offset(50);
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

- (void)registerButtonTapped
{
    NSString *password = userPasswordTextField.text;
    NSString *repassword = userRePasswordTextField.text;
    
    BOOL isError = NO;
    NSString *errorMessage = @"";
    
    if ([@"" isEqualToString:password]) {
        isError = YES;
        errorMessage = @"请输入密码！";
    }
    else if (password.length < 6) {
        isError = YES;
        errorMessage = @"密码不能少于6位！";
    }
    else if (password.length > 14) {
        isError = YES;
        errorMessage = @"密码不能大于14位！";
    }
    else if ([@"" isEqualToString:repassword]) {
        isError = YES;
        errorMessage = @"请输入确认密码！";
    }
    else if (![password isEqualToString:repassword]) {
        isError = YES;
        errorMessage = @"请确认两次密码一致！";
    }
    
    if (isError) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
        return;
    }
    
    [SVProgressHUD show];
    [VANetworkInterface registerWithName:self.name password:password email:self.email sex:@"0" mobile:self.mobile successBlock:^(id responseObject) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showInfoWithStatus:[responseObject objectForKey:@"Message"]];
        [self performSelectorOnMainThread:@selector(navigateToLoginPage) withObject:nil waitUntilDone:NO];
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];

}

- (void)navigateToLoginPage
{
    [self.userPasswordTextField resignFirstResponder];
    [self.userRePasswordTextField resignFirstResponder];
    
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
        if (textField == userPasswordTextField) {
            [userRePasswordTextField becomeFirstResponder];
            return NO;
        }
        else if (textField == userRePasswordTextField) {
            [self registerButtonTapped];
            return NO;
        }
    }
    else if ([string isEqualToString:@" "]){
        return NO;
    }
    else if (![string isEqualToString:@""]) {
        if ((textField == userPasswordTextField || textField == userRePasswordTextField) && textField.text.length >= 50)
            return NO;
    }
    
    return YES;
}
@end
