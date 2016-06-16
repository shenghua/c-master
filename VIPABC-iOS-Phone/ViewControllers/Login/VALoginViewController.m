//
//  VALoginViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/27.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VALoginViewController.h"
#import "VAUserModel.h"
#import "TMNNetworkLogicManager.h"
#import "VARegisterViewController.h"
#import "AppDelegate.h"
#import "VARegisterUserInfoViewController.h"
#import "VANetworkInterface.h"
#import "VATool.h"

@interface VALoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userEmailTextField;
@property (nonatomic, strong) UITextField *userPasswordTextField;

@property (nonatomic, strong) UIButton *loginButton;


@end

@implementation VALoginViewController

@synthesize userEmailTextField, userPasswordTextField, loginButton;

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"SessionRoomClose"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [closeButton addTarget:self action:@selector(dismissLoginViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    self.title = @"登录";
    
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
    userEmailTextField.delegate = self;
    [self.view addSubview:userEmailTextField];
    
    self.userPasswordTextField = [[UITextField alloc] init];
    userPasswordTextField.font = DEFAULT_FONT(16.0);
    userPasswordTextField.tintColor = [UIColor darkGrayColor];
    userPasswordTextField.textColor = [UIColor blackColor];
    userPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密 码" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userPasswordTextField.secureTextEntry = YES;
    userPasswordTextField.keyboardType = UIKeyboardTypeDefault;
    userPasswordTextField.returnKeyType = UIReturnKeyGo;
    userPasswordTextField.delegate = self;
    [self.view addSubview:userPasswordTextField];
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView2];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [loginButton addTarget:self action:@selector(loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"登  录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.backgroundColor = RGBCOLOR(247, 76, 76, 1);
    loginButton.layer.cornerRadius = 8;
//    loginButton.layer.borderColor = [RGBCOLOR(247, 76, 76, 1) CGColor];
//    loginButton.layer.borderWidth = 1;
    [self.view addSubview:loginButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"注 册" forState:UIControlStateNormal];
    [cancelButton setTitleColor:RGBCOLOR(247, 76, 76, 1) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(navigateToRegisterPage) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.hidden = ![VATool isRegisterOpen];
    [self.view addSubview:cancelButton];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginLogo"]];
    [self.view addSubview:logoImageView];
    
    UIImageView *emailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginMail"]];
    [self.view addSubview:emailImageView];
    
    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginPassword"]];
    [self.view addSubview:passwordImageView];
    
    [emailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userEmailTextField);
        make.left.equalTo(self.view).offset(15);
    }];
    
    [passwordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userPasswordTextField);
        make.centerX.equalTo(emailImageView);
    }];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(30);
    }];
    
    [userEmailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@((iPhone5 ? 140.0 : 150.0) * 2));
        make.height.equalTo(@(30.0));
        make.left.equalTo(emailImageView.right).offset(8);
        make.top.equalTo(self.view).offset(120.0);
    }];
    
    [userPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(userEmailTextField);
        make.height.equalTo(userEmailTextField);
        make.centerX.equalTo(userEmailTextField);
        make.top.equalTo(userEmailTextField.bottom).offset(20);
    }];
    
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(1));
        make.left.equalTo(self.view);
        make.top.equalTo(userEmailTextField.bottom).offset(5);
    }];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView1);
        make.height.equalTo(lineView1);
        make.left.equalTo(lineView1);
        make.top.equalTo(userPasswordTextField.bottom).offset(5);
    }];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kScreenWidth - 30));
        make.height.equalTo(@(22.5 * 2));
        make.centerX.equalTo(self.view);
        make.top.equalTo(lineView2).offset(40);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(90.0 * 2));
        make.height.equalTo(loginButton);
        make.centerX.equalTo(loginButton);
        make.top.equalTo(loginButton).offset(50);
    }];
    
    userEmailTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"account"];
//    userPasswordTextField.text = @"vipabc";
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

- (void)loginButtonTapped
{
    NSString *email = userEmailTextField.text;
    NSString *password = userPasswordTextField.text;
    
    BOOL isError = NO;
    NSString *errorMessage = @"";
    
    if ([@"" isEqualToString:email]) {
        isError = YES;
        errorMessage = @"请输入Email！";
    }
    else if ([@"" isEqualToString:password]) {
        isError = YES;
        errorMessage = @"请输入密码！";
    }
    else if (![self isValidateEmail:email]) {
        isError = YES;
        errorMessage = @"请输入正确的Email！";
    }
    
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    if (isError) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
        return;
    }
    
    if (![VANetworkInterface isNetworkReachable]) {
        [SVProgressHUD showErrorWithStatus:@"请检查您的网络设置！"];
        return;
    }
    
    [SVProgressHUD show];
    TMNNetworkLogicController *apiManager = [TMNNetworkLogicManager sharedInstace];
    [apiManager loginWithAccount:email
                         password:password
                          brandId:TMNBrandID_VIPABC
                     successBlock:^(id object) {
                         [SVProgressHUD dismiss];
                         TMUser *user = (TMUser *)object;
                         [[NSUserDefaults standardUserDefaults] setObject:user.account forKey:@"account"];
                         [[NSUserDefaults standardUserDefaults] setObject:user.password forKey:@"password"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         
                         [self dismissLoginViewController];
                     }
                      failedBlock:^(NSError *error, id responseObject) {
                          NSLog(@"[login] fail error:%@, response:%@", error, responseObject);
                          [SVProgressHUD showErrorWithStatus:responseObject];
                      }];
}

- (void)dismissLoginViewController
{
    [self.userEmailTextField resignFirstResponder];
    [self.userPasswordTextField resignFirstResponder];
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    [appDelegate navigateToTabBarPage];
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
        if (textField == userEmailTextField) {
            [userPasswordTextField becomeFirstResponder];
            return NO;
        }
        else if (textField == userPasswordTextField) {
            [self loginButtonTapped];
            return NO;
        }
    }
    else if ([string isEqualToString:@" "]){
        return NO;
    }
    else if (![string isEqualToString:@""]) {
        if (textField == userEmailTextField && textField.text.length >= 100) {
            return NO;
        } else if (textField == userPasswordTextField && textField.text.length >= 50) {
            return NO;
        }
    }
    
    return YES;
}

- (void)navigateToRegisterPage
{
    VARegisterUserInfoViewController *registerVC = [[VARegisterUserInfoViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

@end
