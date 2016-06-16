//
//  VARegisterPhoneVerticalViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/27.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VARegisterPhoneVerticalViewController.h"
#import "VAUserModel.h"
#import "TMNNetworkLogicManager.h"
#import "VARegisterViewController.h"
#import "AppDelegate.h"
#import "VANetworkInterface.h"
#import "VARegisterPasswordViewController.h"

@interface VARegisterPhoneVerticalViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userPhoneTextField;
@property (nonatomic, strong) UITextField *verificationCodeTextField;
@property (nonatomic, strong) UILabel *getVerificationCodeLabel;
@property (nonatomic, strong) UIButton *nextButton;

@property (assign, nonatomic) NSUInteger secondsCountInitialized; //倒计时初始化时秒数
@property (assign, nonatomic) NSUInteger secondsCountDown; //当前倒计时剩余秒数
@property (strong, nonatomic) NSTimer *countDownTimer; //验证码倒计时Timer

@end

@implementation VARegisterPhoneVerticalViewController

@synthesize userPhoneTextField, verificationCodeTextField, nextButton, getVerificationCodeLabel;

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
    
    self.userPhoneTextField = [[UITextField alloc] init];
    userPhoneTextField.font = DEFAULT_FONT(16.0);
    userPhoneTextField.tintColor = [UIColor darkGrayColor];
    userPhoneTextField.textColor = [UIColor blackColor];
    userPhoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userPhoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手 机 号 码" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userPhoneTextField.keyboardType = UIKeyboardTypePhonePad;
    userPhoneTextField.delegate = self;
    userPhoneTextField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:userPhoneTextField];
    
    self.verificationCodeTextField = [[UITextField alloc] init];
    verificationCodeTextField.font = DEFAULT_FONT(16.0);
    verificationCodeTextField.tintColor = [UIColor darkGrayColor];
    verificationCodeTextField.textColor = [UIColor blackColor];
    verificationCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    verificationCodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验 证 码" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    verificationCodeTextField.delegate = self;
    verificationCodeTextField.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:verificationCodeTextField];
    
    self.getVerificationCodeLabel = [[UILabel alloc] init];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendVerificationCode)];
    getVerificationCodeLabel.userInteractionEnabled = YES;
    [getVerificationCodeLabel addGestureRecognizer:gestureRecognizer];
    getVerificationCodeLabel.text = @"获 取 验 证 码";
    getVerificationCodeLabel.textAlignment = NSTextAlignmentCenter;
    getVerificationCodeLabel.font = DEFAULT_FONT(14);
    getVerificationCodeLabel.textColor = RGBCOLOR(247, 76, 76, 1);
    getVerificationCodeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:getVerificationCodeLabel];
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView2];
    
    UIView *lineView3 = [[UIView alloc] init];
    lineView3.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:lineView3];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"下 一 步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.backgroundColor = RGBCOLOR(247, 76, 76, 1);
    nextButton.layer.cornerRadius = 8;
    [self.view addSubview:nextButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"登 录" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(navigateToLoginPage) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.hidden = YES;
    [self.view addSubview:cancelButton];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginLogo"]];
    [self.view addSubview:logoImageView];
    
    UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginCellPhone"]];
    [self.view addSubview:phoneImageView];
    
    UIImageView *codeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VALoginCode"]];
    [self.view addSubview:codeImageView];
    
    [phoneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userPhoneTextField);
        make.left.equalTo(self.view).offset(15);
    }];
    
    [codeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(verificationCodeTextField);
        make.centerX.equalTo(phoneImageView);
    }];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(30);
    }];
    
    [userPhoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@((iPhone5 ? 140.0 : 150.0) * 2));
        make.height.equalTo(@(30.0));
        make.left.equalTo(phoneImageView.right).offset(8);
        make.top.equalTo(self.view).offset(120.0);
    }];
    
    [verificationCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(iPhone5 ? 150 : 180));
        make.height.equalTo(userPhoneTextField);
        make.left.equalTo(userPhoneTextField);
        make.top.equalTo(userPhoneTextField.bottom).offset(20);
    }];
    
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(1));
        make.left.equalTo(self.view);
        make.top.equalTo(userPhoneTextField.bottom).offset(5);
    }];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView1);
        make.height.equalTo(lineView1);
        make.left.equalTo(lineView1);
        make.top.equalTo(verificationCodeTextField.bottom).offset(5);
    }];
    
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(1));
        make.height.equalTo(verificationCodeTextField);
        make.centerY.equalTo(verificationCodeTextField);
        make.left.equalTo(verificationCodeTextField.right).offset(5);
    }];
    
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kScreenWidth - 30));
        make.height.equalTo(@(22.5 * 2));
        make.centerX.equalTo(self.view);
        make.top.equalTo(lineView2).offset(40);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(90.0 * 2));
        make.height.equalTo(nextButton);
        make.centerX.equalTo(nextButton);
        make.top.equalTo(nextButton).offset(50);
    }];
    
    [getVerificationCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(65.0 * 2));
        make.height.equalTo(@(22.5 * 2));
        make.centerY.equalTo(verificationCodeTextField);
        make.left.equalTo(lineView3).offset(6);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UINavigationBar appearance] setBarTintColor:RGBCOLOR(247, 76, 76, 1)];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    self.secondsCountDown=0;
    self.secondsCountInitialized=59;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextButtonTapped
{
    NSString *mobile = userPhoneTextField.text;
    NSString *code = verificationCodeTextField.text;
    
    BOOL isError = NO;
    NSString *errorMessage = @"";
    
    if ([@"" isEqualToString:mobile]) {
        isError = YES;
        errorMessage = @"请输入手机号码！";
    }
    else if (![self isValidateMobile:mobile]) {
        isError = YES;
        errorMessage = @"请输入正确的手机号码！";
    }
    else if ([@"" isEqualToString:code]) {
        isError = YES;
        errorMessage = @"请输入验证码！";
    }
    
    if (isError) {
        [SVProgressHUD showErrorWithStatus:errorMessage];
        return;
    }
    
    [SVProgressHUD show];
    [VANetworkInterface checkEmail:self.email mobile:mobile successBlock:^(id responseObject) {
        [VANetworkInterface verificateCodeWithMobileNo:mobile code:verificationCodeTextField.text successBlock:^(id responseObject) {
            [SVProgressHUD dismiss];
            
            VARegisterPasswordViewController *registerPasswordVC = [[VARegisterPasswordViewController alloc] init];
            registerPasswordVC.name = self.name;
            registerPasswordVC.email = self.email;
            registerPasswordVC.mobile = mobile;
            
            [self.navigationController pushViewController:registerPasswordVC animated:YES];
        } failedBlock:^(NSError *error, id responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject];
        }];
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];

}

// 手机号验证
-(BOOL)isValidateMobile:(NSString *)mobile
{
    //    NSString *mobileRegex = @"^1[3,5,8][0-9]{9}$";
    NSString *mobileRegex = @"^1[0-9]{10}$";
    NSPredicate *mobilePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    return [mobilePredicate evaluateWithObject:mobile];
}

- (void)navigateToLoginPage
{
    [self.userPhoneTextField resignFirstResponder];
    [self.verificationCodeTextField resignFirstResponder];
    
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

//启动验证码重新发送倒计时器
- (void)startVerificationCodeTimer {
    self.secondsCountDown=self.secondsCountInitialized;
    
//    getVerificationCodeLabel.backgroundColor = RGBCOLOR(247, 76, 76, 1);
//    getVerificationCodeLabel.textColor = [UIColor whiteColor];
    getVerificationCodeLabel.text = [NSString stringWithFormat:@"%lu秒后重新获取", (unsigned long)self.secondsCountDown];
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

-(void)timeFireMethod{
    self.secondsCountDown--;
    
    if (self.secondsCountDown<=0) {
        [self.countDownTimer invalidate];
        getVerificationCodeLabel.text = @"获 取 验 证 码";
        getVerificationCodeLabel.userInteractionEnabled = YES;
        
        return;
    }
    
    getVerificationCodeLabel.text = [NSString stringWithFormat:@"%lu秒后重新获取", (unsigned long)self.secondsCountDown];
}

- (void)sendVerificationCode
{
    if (self.secondsCountDown>0) {
        return;
    }else{
        NSString *mobileNo = userPhoneTextField.text;
        
        BOOL isError = NO;
        NSString *errorMessage = @"";
        if ([@"" isEqualToString:mobileNo]) {
            isError = YES;
            errorMessage = @"请输入手机号码！";
        }
        else if (![self isValidateMobile:mobileNo]) {
            isError = YES;
            errorMessage = @"请输入正确的手机号码！";
        }
        
        if (isError) {
            [SVProgressHUD showErrorWithStatus:errorMessage];
            return;
        }
        
        [SVProgressHUD show];
        [VANetworkInterface sendVerificationCodeWithMobileNo:userPhoneTextField.text successBlock:^(id responseObject) {
            [SVProgressHUD dismiss];
            getVerificationCodeLabel.userInteractionEnabled = NO;
            [self startVerificationCodeTimer];
        } failedBlock:^(NSError *error, id responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject];
        }];
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        if (textField == userPhoneTextField) {
            [verificationCodeTextField becomeFirstResponder];
            return NO;
        }
        else if (textField == verificationCodeTextField) {
            [self nextButtonTapped];
            return NO;
        }
    }
    else if ([string isEqualToString:@" "]){
        return NO;
    }
    else if (![string isEqualToString:@""]) {
        if (textField == userPhoneTextField && textField.text.length >= 11)
            return NO;
        else if (textField == verificationCodeTextField && textField.text.length >= 6)
            return NO;
    }
    
    return YES;
}
@end
