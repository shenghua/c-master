//
//  VARegisterViewController.m
//  VIPABC4Phone
//
//  Created by uther on 16/1/14.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VARegisterViewController.h"
#import "VANetworkInterface.h"
#import "VAUserModel.h"

@interface VARegisterViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userNameTextField;
@property (nonatomic, strong) UITextField *userEmailTextField;
@property (nonatomic, strong) UITextField *userMobileTextField;
@property (nonatomic, strong) UITextField *verificationCodeTextField;
@property (nonatomic, strong) UITextField *userPasswordTextField;
@property (nonatomic, strong) UITextField *userRePasswordTextField;
@property (nonatomic, strong) UILabel *getVerificationCodeLabel;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (assign, nonatomic) NSUInteger secondsCountInitialized; //倒计时初始化时秒数
@property (assign, nonatomic) NSUInteger secondsCountDown; //当前倒计时剩余秒数
@property (strong, nonatomic) NSTimer *countDownTimer; //验证码倒计时Timer

@end

@implementation VARegisterViewController

@synthesize userNameTextField, userEmailTextField, userMobileTextField, verificationCodeTextField, userPasswordTextField, userRePasswordTextField, getVerificationCodeLabel, registerButton, cancelButton;

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"VALoginClose"] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"VALoginClose"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [closeButton addTarget:self action:@selector(dismissRegisterViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UILabel *memberTipLabel = [[UILabel alloc] init];
    memberTipLabel.text = @"我是会员";
    memberTipLabel.textColor = RGBCOLOR(247, 76, 76, 1);
    memberTipLabel.font = DEFAULT_FONT(16.0);
    [memberTipLabel sizeToFit];
    [self.view addSubview:memberTipLabel];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissRegisterViewController)];
    memberTipLabel.userInteractionEnabled = YES;
    [memberTipLabel addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissRegisterViewController)];
    [memberTipLabel addGestureRecognizer:gesture];
    
    self.userNameTextField = [[UITextField alloc] init];
    [userNameTextField becomeFirstResponder];
    userNameTextField.font = DEFAULT_FONT(16.0);
    userNameTextField.tintColor = [UIColor darkGrayColor];
    userNameTextField.textColor = [UIColor darkGrayColor];
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"用户名" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userNameTextField.keyboardType = UIKeyboardTypeDefault;
    userNameTextField.delegate = self;
    [self.view addSubview:userNameTextField];
    
    self.userEmailTextField = [[UITextField alloc] init];
    userEmailTextField.font = DEFAULT_FONT(16.0);
    userEmailTextField.tintColor = [UIColor darkGrayColor];
    userEmailTextField.textColor = [UIColor darkGrayColor];
    userEmailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userEmailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"邮箱" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    userEmailTextField.delegate = self;
    [self.view addSubview:userEmailTextField];
    
    self.userMobileTextField = [[UITextField alloc] init];
    userMobileTextField.font = DEFAULT_FONT(16.0);
    userMobileTextField.tintColor = [UIColor darkGrayColor];
    userMobileTextField.textColor = [UIColor darkGrayColor];
    userMobileTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userMobileTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号码" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userMobileTextField.keyboardType = UIKeyboardTypePhonePad;
    userMobileTextField.delegate = self;
    [self.view addSubview:userMobileTextField];
    
    self.verificationCodeTextField = [[UITextField alloc] init];
    verificationCodeTextField.font = DEFAULT_FONT(16.0);
    verificationCodeTextField.tintColor = [UIColor darkGrayColor];
    verificationCodeTextField.textColor = [UIColor darkGrayColor];
    verificationCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    verificationCodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    verificationCodeTextField.delegate = self;
    [self.view addSubview:verificationCodeTextField];
    
    self.getVerificationCodeLabel = [[UILabel alloc] init];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendVerificationCode)];
    getVerificationCodeLabel.userInteractionEnabled = YES;
    [getVerificationCodeLabel addGestureRecognizer:gestureRecognizer];
    getVerificationCodeLabel.text = @"获取验证码";
    getVerificationCodeLabel.textAlignment = NSTextAlignmentCenter;
    getVerificationCodeLabel.font = DEFAULT_FONT(14);
    getVerificationCodeLabel.textColor = RGBCOLOR(247, 76, 76, 1);
    getVerificationCodeLabel.layer.cornerRadius = 22;
    getVerificationCodeLabel.layer.borderColor = [RGBCOLOR(247, 76, 76, 1) CGColor];
    getVerificationCodeLabel.layer.borderWidth = 1;
    getVerificationCodeLabel.layer.masksToBounds = YES;
    [self.view addSubview:getVerificationCodeLabel];
    
    self.userPasswordTextField = [[UITextField alloc] init];
    userPasswordTextField.font = DEFAULT_FONT(16.0);
    userPasswordTextField.tintColor = [UIColor darkGrayColor];
    userPasswordTextField.textColor = [UIColor darkGrayColor];
    userPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码 6-14位英文或数字" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userPasswordTextField.secureTextEntry = YES;
    userPasswordTextField.keyboardType = UIKeyboardTypeDefault;
    userPasswordTextField.returnKeyType = UIReturnKeyGo;
    userPasswordTextField.delegate = self;
    [self.view addSubview:userPasswordTextField];
    
    self.userRePasswordTextField = [[UITextField alloc] init];
    userRePasswordTextField.font = DEFAULT_FONT(16.0);
    userRePasswordTextField.tintColor = [UIColor darkGrayColor];
    userRePasswordTextField.textColor = [UIColor darkGrayColor];
    userRePasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userRePasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"确认密码" attributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    userRePasswordTextField.secureTextEntry = YES;
    userRePasswordTextField.keyboardType = UIKeyboardTypeDefault;
    userRePasswordTextField.returnKeyType = UIReturnKeyGo;
    userRePasswordTextField.delegate = self;
    [self.view addSubview:userRePasswordTextField];
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView2];
    
    UIView *lineView3 = [[UIView alloc] init];
    lineView3.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView3];
    
    UIView *lineView4 = [[UIView alloc] init];
    lineView4.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView4];
    
    UIView *lineView5 = [[UIView alloc] init];
    lineView5.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView5];
    
    UIView *lineView6 = [[UIView alloc] init];
    lineView6.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView6];
    
//    self.getVerificationCodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [getVerificationCodeButton addTarget:self action:@selector(sendVerificationCode) forControlEvents:UIControlEventTouchUpInside];
//    [getVerificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
//    [getVerificationCodeButton setTitleColor:RGBCOLOR(247, 76, 76, 1) forState:UIControlStateNormal];
//    getVerificationCodeButton.layer.cornerRadius = 22;
//    getVerificationCodeButton.layer.borderColor = [RGBCOLOR(247, 76, 76, 1) CGColor];
//    getVerificationCodeButton.layer.borderWidth = 1;
//    [self.view addSubview:getVerificationCodeButton];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注  册" forState:UIControlStateNormal];
    [registerButton setTitleColor:RGBCOLOR(247, 76, 76, 1) forState:UIControlStateNormal];
    registerButton.layer.cornerRadius = 22;
    registerButton.layer.borderColor = [RGBCOLOR(247, 76, 76, 1) CGColor];
    registerButton.layer.borderWidth = 1;
    [self.view addSubview:registerButton];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:@"稍  后" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    cancelButton.layer.cornerRadius = 22;
    [cancelButton addTarget:self action:@selector(dismissRegisterViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    
    // Add Constraints
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(20.0));
        make.top.equalTo(@(40.0));
    }];
    
    [memberTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(closeButton.top);
        make.right.equalTo(@(-20.0));
    }];
    
    [userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(127.0 * 2));
        make.height.equalTo(@(30.0));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(90.0);
    }];
    
    [userEmailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(userNameTextField);
        make.height.equalTo(userNameTextField);
        make.centerX.equalTo(userNameTextField);
        make.top.equalTo(userNameTextField.bottom).offset(iPhone6 ? 40 : 30);
    }];
    
    [userMobileTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(userNameTextField);
        make.height.equalTo(userNameTextField);
        make.centerX.equalTo(userNameTextField);
        make.top.equalTo(userEmailTextField.bottom).offset(iPhone6 ? 40 : 30);
    }];
    
    [verificationCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView4);
        make.height.equalTo(userNameTextField);
        make.left.equalTo(userNameTextField);
        make.top.equalTo(userMobileTextField.bottom).offset(iPhone6 ? 40 : 30);
    }];
    
    [getVerificationCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(65.0 * 2));
        make.height.equalTo(@(22.5 * 2));
        make.centerX.equalTo(@(45.0 * 2));
        make.top.equalTo(userMobileTextField.bottom).offset(30);
    }];
    
    [userPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(userNameTextField);
        make.height.equalTo(userNameTextField);
        make.centerX.equalTo(userNameTextField);
        make.top.equalTo(verificationCodeTextField.bottom).offset(iPhone6 ? 40 : 30);
    }];
    
    [userRePasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(userNameTextField);
        make.height.equalTo(userNameTextField);
        make.centerX.equalTo(userNameTextField);
        make.top.equalTo(userPasswordTextField.bottom).offset(iPhone6 ? 40 : 30);
    }];
    
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(userNameTextField);
        make.height.equalTo(@(1.5));
        make.left.equalTo(userNameTextField);
        make.top.equalTo(userNameTextField.bottom).offset(10);
    }];
    
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView1);
        make.height.equalTo(lineView1);
        make.left.equalTo(userEmailTextField);
        make.top.equalTo(userEmailTextField.bottom).offset(10);
    }];
    
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView1);
        make.height.equalTo(lineView1);
        make.left.equalTo(userMobileTextField);
        make.top.equalTo(userMobileTextField.bottom).offset(10);
    }];
    
    [lineView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(77.0 * 2));
        make.height.equalTo(lineView1);
        make.left.equalTo(verificationCodeTextField);
        make.top.equalTo(verificationCodeTextField.bottom).offset(10);
    }];
    
    [lineView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView1);
        make.height.equalTo(lineView1);
        make.left.equalTo(userPasswordTextField);
        make.top.equalTo(userPasswordTextField.bottom).offset(10);
    }];
    
    [lineView6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(lineView1);
        make.height.equalTo(lineView1);
        make.left.equalTo(userRePasswordTextField);
        make.top.equalTo(userRePasswordTextField.bottom).offset(10);
    }];
    
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(90.0 * 2));
        make.height.equalTo(getVerificationCodeLabel);
        make.centerX.equalTo(userRePasswordTextField);
        make.top.equalTo(lineView6).offset(iPhone6 ? 40 : 30);
    }];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(90.0 * 2));
        make.height.equalTo(registerButton);
        make.centerX.equalTo(registerButton);
        make.top.equalTo(registerButton).offset(iPhone6 ? 50 : 40);
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.secondsCountDown=0;
    self.secondsCountInitialized=59;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerButtonTapped
{
    NSString *name = userNameTextField.text;
    NSString *email = userEmailTextField.text;
    NSString *mobile = userMobileTextField.text;
    NSString *code = verificationCodeTextField.text;
    NSString *password = userPasswordTextField.text;
    NSString *repassword = userRePasswordTextField.text;
    
    BOOL isError = NO;
    NSString *errorMessage = @"";
    
    if ([@"" isEqualToString:name]) {
        isError = YES;
        errorMessage = @"请输入用户名！";
    }
    //用户名长度判断
    else if ([@"" isEqualToString:email]) {
        isError = YES;
        errorMessage = @"请输入邮箱！";
    }
    else if (![self isValidateEmail:email]) {
        isError = YES;
        errorMessage = @"请输入正确的邮箱！";
    }
    else if ([@"" isEqualToString:mobile]) {
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
    else if ([@"" isEqualToString:password]) {
        isError = YES;
        errorMessage = @"请输入密码！";
    }
    else if (password.length < 6) {
        isError = YES;
        errorMessage = @"密码不能少于6位！";
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
    [VANetworkInterface checkEmail:userEmailTextField.text mobile:userMobileTextField.text successBlock:^(id responseObject) {
        [VANetworkInterface verificateCodeWithMobileNo:userMobileTextField.text code:verificationCodeTextField.text successBlock:^(id responseObject) {
            [VANetworkInterface registerWithName:name password:password email:email sex:@"0" mobile:mobile successBlock:^(id responseObject) {
                [SVProgressHUD showInfoWithStatus:[responseObject objectForKey:@"Message"]];
                [self performSelectorOnMainThread:@selector(dismissRegisterViewController) withObject:nil waitUntilDone:NO];
            } failedBlock:^(NSError *error, id responseObject) {
                [SVProgressHUD showErrorWithStatus:responseObject];
            }];
        } failedBlock:^(NSError *error, id responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject];
        }];
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
}

- (void)sendVerificationCode
{
    if (self.secondsCountDown>0) {
        return;
    }else{
        NSString *mobileNo = userMobileTextField.text;
        
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
        [VANetworkInterface sendVerificationCodeWithMobileNo:userMobileTextField.text successBlock:^(id responseObject) {
            [SVProgressHUD dismiss];
            getVerificationCodeLabel.userInteractionEnabled = NO;
            [self startVerificationCodeTimer];
        } failedBlock:^(NSError *error, id responseObject) {
            [SVProgressHUD showErrorWithStatus:@"获取验证码失败！"];
//            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"Status"] objectForKey:@"msg"]];
        }];
    }
    
}

- (void)dismissRegisterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 邮箱验证
-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:email];
}

// 手机号验证
-(BOOL)isValidateMobile:(NSString *)mobile
{
//    NSString *mobileRegex = @"^1[3,5,8][0-9]{9}$";
    NSString *mobileRegex = @"^1[0-9]{10}$";
    NSPredicate *mobilePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    return [mobilePredicate evaluateWithObject:mobile];
}

// 验证用户名(支持中英文)
- (BOOL)isValidateName:(NSString *)name
{
    NSString *nameRegex = @"^[\u4e00-\u9fa5_a-zA-Z]+$";
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    
    BOOL isValidate = [namePredicate evaluateWithObject:name];
    
    if (!isValidate)
        [SVProgressHUD showErrorWithStatus:@"仅可输入中文和英文哦"];
    return isValidate;
}

//启动验证码重新发送倒计时器
- (void)startVerificationCodeTimer {
    self.secondsCountDown=self.secondsCountInitialized;
    
    getVerificationCodeLabel.backgroundColor = RGBCOLOR(247, 76, 76, 1);
    getVerificationCodeLabel.textColor = [UIColor whiteColor];
    getVerificationCodeLabel.text = [NSString stringWithFormat:@"%lu秒后重新获取", (unsigned long)self.secondsCountDown];
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

-(void)timeFireMethod{
    self.secondsCountDown--;
    
    if(self.secondsCountDown<=0){
        [self.countDownTimer invalidate];
        getVerificationCodeLabel.text = @"获取验证码";
        getVerificationCodeLabel.textColor = RGBCOLOR(247, 76, 76, 1);
        getVerificationCodeLabel.backgroundColor = [UIColor whiteColor];
        getVerificationCodeLabel.userInteractionEnabled = YES;
        
        return;
    }
    
    getVerificationCodeLabel.text = [NSString stringWithFormat:@"%lu秒后重新获取", (unsigned long)self.secondsCountDown];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]){
        return NO;
    }
    else if (![string isEqualToString:@""]) {
        if (textField == userNameTextField && (textField.text.length >= 30 || ![self isValidateName:string]))
            return NO;
        else if (textField == userEmailTextField && textField.text.length >= 100)
            return NO;
        else if (textField == userMobileTextField && textField.text.length >= 11)
            return NO;
        else if (textField == verificationCodeTextField && textField.text.length >= 6)
            return NO;
        else if ((textField == userPasswordTextField || textField == userRePasswordTextField) && textField.text.length >= 50)
            return NO;
    }
    
    return YES;
}

@end
