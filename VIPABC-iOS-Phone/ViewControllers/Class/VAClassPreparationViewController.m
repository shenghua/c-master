//
//  VAClassPreparationViewController.m
//  VIPABC4Phone
//
//  Created by ledka on 16/1/9.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAClassPreparationViewController.h"
#import "VATool.h"
#import "TMNNetworkLogicController.h"
#import "TMNNetworkLogicManager.h"
#import "UIImageView+WebCache.h"
#import "VAMaterialViewController.h"
#import "VAClassRoomViewController.h"
#import "TMNNetworkLogicManager.h"
#import "TMNNetworkLogicController.h"
#import "TMResponse.h"
#import "TMNextSessionInfo.h"
#import "VASessionRoom1ViewController.h"
#import "TutormeetBroker.h"
#import "VACustomerNavigationController.h"

#define VA_ENTER_SESSION_ROOM_TIME_BEFORE 3 * 60

#define kLoginApiHost @"http://mobapi.tutorabc.com/mobcommon/webapi/user/1/login"

@interface VAClassPreparationViewController ()

@property (nonatomic, strong) NSTimer *enterClassRoomtimer;

@property (nonatomic, strong) UILabel *cutdownLabel1;
@property (nonatomic ,strong) UILabel *cutdownMinutesLabel;
@property (nonatomic, strong) UILabel *cutdownLabel2;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIView *cutdownView;
@property (nonatomic, strong) UIView *canEnterClassRoomLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *waitLabel;

@end

@implementation VAClassPreparationViewController

@synthesize classInfo, consultant, enterClassRoomtimer, cutdownLabel1, cutdownMinutesLabel, cutdownLabel2, previewButton, cutdownView, canEnterClassRoomLabel, titleLabel, waitLabel;

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
    self.title = @"教材预览";
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"SessionRoomClose"] forState:UIControlStateNormal];
    closeButton.contentMode = UIViewContentModeScaleAspectFit;
    closeButton.frame = CGRectMake(0, 0, 25, 25);
    [closeButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.rightBarButtonItem = closeBarButtonItem;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UINavigationBar appearance] setBarTintColor:RGBCOLOR(247, 76, 76, 1)];
    
//    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"VABack"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
//    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    TMNNetworkLogicController *apiManager = [TMNNetworkLogicManager sharedInstace];
//    [apiManager getNextSession:[date timeIntervalSinceNow] successBlock:^(id object) {
//        
//    } failedBlock:^(NSError *error, id responseObject) {
//        
//    }];
    
    UILabel *nameLabel = [VATool getLabelWithTextString:[NSString stringWithFormat:@"Hi %@", apiManager.currentUser.usernameEn] fontSize:15.0 textColor:[UIColor darkGrayColor] sapce:0 bold:YES];
    [self.view addSubview:nameLabel];
    
//    NSArray *array = [classInfo.sessionBeginDate componentsSeparatedByString:@" "];
    
    NSString *time = [self formatBeginTime:classInfo.sessionBeginDate];//[array objectAtIndex:array.count > 0 ? 1 : 0];
    UILabel *timeLabel = [VATool getLabelWithTextString:[NSString stringWithFormat:@"您预约在 %@ 的课程", time] fontSize:15.0 textColor:[UIColor darkGrayColor] sapce:0 bold:NO];
    [self.view addSubview:timeLabel];
    
    self.titleLabel = [VATool getLabelWithTextString:classInfo.sessionTitleCN fontSize:18 textColor:[UIColor blackColor] sapce:0 bold:YES];
    [self.view addSubview:titleLabel];
    
    self.cutdownView = [[UIView alloc] init];
    cutdownView.backgroundColor = [UIColor clearColor];
    [cutdownView sizeToFit];
    cutdownView.hidden = YES;
    
    self.cutdownLabel1= [VATool getLabelWithTextString:@"还有" fontSize:16 textColor:[UIColor darkGrayColor] sapce:0 bold:NO];
    self.cutdownMinutesLabel = [VATool getLabelWithTextString:[NSString stringWithFormat:@"%ld", [self minutesOfCanEnterClassRoom]] fontSize:18 textColor:RGBCOLOR(247, 76, 76, 1) sapce:0 bold:NO];
    self.cutdownLabel2 = [VATool getLabelWithTextString:@"分钟可以进教室" fontSize:16 textColor:[UIColor darkGrayColor] sapce:0 bold:NO];
    
    [cutdownView addSubview:cutdownLabel1];
    [cutdownView addSubview:cutdownMinutesLabel];
    [cutdownView addSubview:cutdownLabel2];
    
    [cutdownLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerY.equalTo(cutdownView);
        make.left.equalTo(cutdownView).offset(0);
    }];
    [cutdownMinutesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerY.equalTo(cutdownLabel1);
        make.left.equalTo(cutdownLabel1.right).offset(5);
    }];
    [cutdownLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerY.equalTo(cutdownLabel1);
        make.left.equalTo(cutdownMinutesLabel.right).offset(5);
    }];
    
    [self.view addSubview:cutdownView];
    
    self.canEnterClassRoomLabel = [VATool getLabelWithTextString:@"已经开始上课了" fontSize:16 textColor:[UIColor darkGrayColor] sapce:0 bold:NO];
    canEnterClassRoomLabel.hidden = YES;
    [self.view addSubview:canEnterClassRoomLabel];
    
    UIImageView *teacherImageView = [[UIImageView alloc] init];
    [teacherImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.vipabc.com/con_img/%ld.jpg", (long)consultant.consultantSn]] placeholderImage:nil];
    teacherImageView.layer.masksToBounds = YES;
    teacherImageView.layer.cornerRadius = 30;
    teacherImageView.contentMode = UIViewContentModeScaleAspectFill;
    teacherImageView.clipsToBounds  = YES;
    [self.view addSubview:teacherImageView];
    
    UILabel *teacherNameLabel = [VATool getLabelWithTextString:[NSString stringWithFormat:@"%@ %@", consultant.firstName, consultant.lastName] fontSize:14 textColor:[UIColor darkGrayColor] sapce:0 bold:NO];
    [self.view addSubview:teacherNameLabel];
    
    previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [previewButton setTitleColor:RGBCOLOR(247, 76, 76, 1) forState:UIControlStateNormal];
    previewButton.layer.cornerRadius = 26;
    previewButton.layer.borderColor = [RGBCOLOR(247, 76, 76, 1) CGColor];
    previewButton.layer.borderWidth = 1;
    [self.view addSubview:previewButton];
    
    self.waitLabel = [VATool getLabelWithTextString:@"预 习 教 材" fontSize:14 textColor:RGBCOLOR(247, 76, 76, 1) sapce:0 bold:NO];
    waitLabel.userInteractionEnabled = YES;
    waitLabel.hidden = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewMaterial)];
    [waitLabel addGestureRecognizer:labelTapGestureRecognizer];
    [self.view addSubview:waitLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(iPhone5 ? 40 : 70);
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(nameLabel);
        make.top.equalTo(nameLabel).offset(45);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(nameLabel);
        make.top.equalTo(timeLabel).offset(27);
        make.width.equalTo(@(kScreenWidth - 20));
    }];
    
    [cutdownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(titleLabel).offset(iPhone6 ? 60 : 50);
        float width = cutdownLabel1.bounds.size.width + cutdownMinutesLabel.bounds.size.width + cutdownLabel2.bounds.size.width;
        make.width.equalTo(@(width));
    }];
    
    [canEnterClassRoomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(nameLabel);
        make.top.equalTo(titleLabel).offset(iPhone6 ? 60 : 50);
    }];
    
    [teacherImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
        make.centerX.equalTo(nameLabel);
        make.top.equalTo(cutdownView).offset(50);
    }];
    
    [teacherNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(nameLabel);
        make.top.equalTo(teacherImageView).offset(70);
    }];
    
    [previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(90.0 * 2));
        make.height.equalTo(@(26 * 2));
        make.centerX.equalTo(nameLabel);
        make.top.equalTo(cutdownView).offset(iPhone6 ? 200 : 190);
    }];
    
    [waitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(nameLabel);
        make.top.equalTo(previewButton).offset(70);
    }];
    
    [self timerFire];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 上课剩余时间定时器
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    self.enterClassRoomtimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:enterClassRoomtimer forMode:NSRunLoopCommonModes];
    
    VACustomerNavigationController *customerNavigationVC = (VACustomerNavigationController *) self.navigationController;
    customerNavigationVC.allowLandscape = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [enterClassRoomtimer invalidate];
    self.enterClassRoomtimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)formatBeginTime:(NSString *)beginTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *beginDate = [formatter dateFromString:beginTime];
    
    [formatter setDateFormat:@"HH:mm"];
    
    return [formatter stringFromDate:beginDate];
}

- (void)timerFire
{
    long minute = [self minutesOfCanEnterClassRoom];
    
    // 已经开始上课
    if (minute <= -3) {
        [enterClassRoomtimer invalidate];

        cutdownView.hidden = YES;
        canEnterClassRoomLabel.hidden = NO;
        
        [previewButton removeTarget:self action:@selector(previewMaterial) forControlEvents:UIControlEventTouchUpInside];
        [previewButton addTarget:self action:@selector(enterClassRoom) forControlEvents:UIControlEventTouchUpInside];
        [previewButton setTitle:@"进 入 教 室" forState:UIControlStateNormal];
        
        self.waitLabel.hidden = NO;
    }
    else {
        cutdownView.hidden = NO;
        canEnterClassRoomLabel.hidden = YES;
        
        cutdownLabel1.text = @"还有";
        
        // 可以进入教室
        if (minute <= 0) {
            cutdownLabel2.text = @"分钟将开始上课";
            cutdownMinutesLabel.text = [NSString stringWithFormat:@"%ld", minute + 3];
            [previewButton removeTarget:self action:@selector(previewMaterial) forControlEvents:UIControlEventTouchUpInside];
            [previewButton addTarget:self action:@selector(enterClassRoom) forControlEvents:UIControlEventTouchUpInside];
            [previewButton setTitle:@"进 入 教 室" forState:UIControlStateNormal];
            
            self.waitLabel.hidden = NO;
        }
        // 还有几分钟可以进入教室
        else {
            cutdownLabel2.text = @"分钟可以进教室";
            cutdownMinutesLabel.text = [NSString stringWithFormat:@"%ld", minute + 1];
            [previewButton removeTarget:self action:@selector(enterClassRoom) forControlEvents:UIControlEventTouchUpInside];
            [previewButton addTarget:self action:@selector(previewMaterial) forControlEvents:UIControlEventTouchUpInside];
            [previewButton setTitle:@"预 习 教 材" forState:UIControlStateNormal];
            
            self.waitLabel.hidden = YES;
        }
        
        [cutdownView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(titleLabel).offset(iPhone6 ? 60 : 50);
            float width = cutdownLabel1.bounds.size.width + cutdownMinutesLabel.bounds.size.width + cutdownLabel2.bounds.size.width;
            make.width.equalTo(@(width));
        }];
        
        [self.view layoutIfNeeded];
    }
}

// 计算可以进入教室的剩余时间
- (long)minutesOfCanEnterClassRoom
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 2015-12-17 17:30:00
    
    NSDate *sessionBeginDate = [dateFormatter dateFromString:classInfo.sessionBeginDate];
    
    NSTimeInterval timeInterval = [sessionBeginDate timeIntervalSinceNow] - VA_ENTER_SESSION_ROOM_TIME_BEFORE;
    
    long minute = timeInterval / 60;
    
    if (timeInterval > 0 && timeInterval < 60)
        minute = 1;
    
    return minute;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Events
- (void)dismissViewController
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kHasTappedWaitButton];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)previewMaterial
{
    VAMaterialViewController *materialVC = [[VAMaterialViewController alloc] init];
    materialVC.classinfo = self.classInfo;
    [self.navigationController pushViewController:materialVC animated:YES];
}

- (void)enterClassRoom
{
    TMNNetworkLogicController *network = [TMNNetworkLogicManager sharedInstace];
    
    [SVProgressHUD show];
    
    [network getEnterRoomInfo:classInfo.sessionSn successBlock:^(id responseObject){
        TMDictResponse *enterClassResponse = responseObject;
        
        if (1 == [[enterClassResponse.data objectForKey:@"canEnter"] intValue]) {
//            IsGotoClass=YES;
//            if ([network currentUser].powerSession)[self checkin];
            // eddy added to enter session for tempnetworkorary
            NSDictionary *responseOfEnterSession = [enterClassResponse.data objectForKey:@"classInfo"];
    
            NSDictionary *classinfo = @{@"ClassType": [responseOfEnterSession objectForKey:@"classType"],
                                        @"CompStatus": [responseOfEnterSession objectForKey:@"compStatus"],
                                        @"SessionRoomId": [responseOfEnterSession objectForKey:@"sessionRoomId"],
                                        @"RoomRandString": [responseOfEnterSession objectForKey:@"randStr"],
                                        @"SessionSn": [responseOfEnterSession objectForKey:@"sessionSn"],
                                        @"ClientSn": [network currentUser].clientSn, };
            
//            NSDictionary *classinfo = @{@"ClassType" : @"8", @"ClientSn" : @"1043510",
//                                        @"CompStatus" : @"abc",
//                                        @"RoomRandString" : @"D367D95C9B",
//                                        @"SessionRoomId" : @"session861",
//                                        @"SessionSn" : @"2016012115861"};
            
            [self showLiveSessionType2WithClassInfo:classinfo];
        }
        else [self checkafterclass];
        
        
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
}

-(void)checkin{
    TMNNetworkLogicController *network = [TMNNetworkLogicManager sharedInstace];
    
    [SVProgressHUD show];
    [network getTimesuccessBlock:^(id responseObject){
        
        long long nowtime=[[responseObject valueForKey:@"now"]longLongValue];
        
        [network getNextSession:nowtime successBlock:^(id responseObject) {
            
            TMNextSessionInfo *info=responseObject;
            
            if (info.sessionSn) {
                //info.classType =6;
                //判斷是否為小班制
                if(info.classType ==TMNClassSessionType_1on6){
                    //判斷是否報到過
                    if (!info.checkInStatus) {
                        
                        [network checkInLesson:info.sessionSn successBlock: ^(id responseObject){
                            [SVProgressHUD dismiss];
                            //報到end
                            
                        }failedBlock:^(NSError *error, id responseObject) {
                            [SVProgressHUD showErrorWithStatus:responseObject];
                        }];
                    }
                    
                }
                
            }
            
        } failedBlock:^(NSError *error, id responseObject) {
            [SVProgressHUD showErrorWithStatus:responseObject];
        }];
        
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
}

-(void)checkafterclass{
    
    [SVProgressHUD show];
    [[TMNNetworkLogicManager sharedInstace] getTimesuccessBlock:^(id responseObject){
        [SVProgressHUD dismiss];
        
        long long nowtime=[[responseObject valueForKey:@"now"]longLongValue];
        long long timeleft=(nowtime-classInfo.sessionEndDateTS)/1000;
        if (timeleft>0) {
            [SVProgressHUD showErrorWithStatus:@"课程已结束！"];
        }
        else{
            
        }
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
    
}

- (void)showLiveSessionType2WithClassInfo:(NSDictionary * _Nonnull)classinfo
{
//    __weak id weakSelf = self;
    NSString *sessionSn = classinfo[@"SessionSn"];
    NSString *sessionRoomId = classinfo[@"SessionRoomId"];
    NSString *sessionRoomRandStr = classinfo[@"RoomRandString"];
    NSString *classType = classinfo[@"ClassType"];
    NSString *compStatus = classinfo[@"CompStatus"];
    NSString *userSn = classinfo[@"ClientSn"];
    
    void (^startSession)(NSDictionary *) = ^void (NSDictionary *data) {
        [SVProgressHUD dismiss];
        if (!data || !data[@"ename"]) {
            NSLog(@"Error, data is invalid");
            NSError *err = [[NSError alloc] initWithDomain:NSArgumentDomain
                                                      code:100002
                                                  userInfo:@{NSLocalizedDescriptionKey: @"data is invalid"}];
//            if (completionHandler) completionHandler(err);
            return;
        }
        
        VASessionRoom1ViewController *sessionRoom = [[VASessionRoom1ViewController alloc] init];
        sessionRoom.classInfo = data;
        
        [self presentViewController:sessionRoom animated:YES completion:nil];
//        dispatch_async(dispatch_get_main_queue(), ^{
//        [self.navigationController pushViewController:sessionRoom animated:YES];
//        });
    };
    
    // Get session room info
    [TutormeetBroker retriveSessionInfoWithSessionSn:sessionSn
                                       sessionRoomId:sessionRoomId
                                  sessionRoomRandStr:sessionRoomRandStr
                                           classType:classType
                                          compStatus:compStatus
                                              userSn:userSn
                                          completion:startSession];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)retriveSessionRoomInfo:(void (^)(NSDictionary *data))completionHandler {
    
    //    if (!_emailTextField.text.length || !_pwdTextField.text.length) {
    //        [SVProgressHUD showInfoWithStatus:@"QA mode"];
    //        if (completionHandler) completionHandler(nil);
    //        return;
    //    }
    
    NSString *email = @"summerayxia@vipabc.com";
    NSString *password = @"xialei";
    [SVProgressHUD show];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLComponents *url = [[NSURLComponents alloc] initWithString:kLoginApiHost];
    url.query = [@[[NSString stringWithFormat:@"deviceId=%@", @"386B2BA574FC4D0385F94ABC16185618"],
                   [NSString stringWithFormat:@"brandId=%@", @"2"],
                   [NSString stringWithFormat:@"account=%@", email],
                   [NSString stringWithFormat:@"password=%@", password]]
                 componentsJoinedByString:@"&"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:@"Login Fail QQ"];
            });
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSLog(@"client login: %@", json);
        //        [[Crashlytics sharedInstance] setObjectValue:json forKey:@"loginapi"];
        
        NSString *clientSn = [json[@"data"] isKindOfClass:NSDictionary.class]? json[@"data"][@"clientSn"]: @"";
        if (clientSn.length) {
            //            [[Crashlytics sharedInstance] setUserIdentifier:clientSn];
            
            NSURL *enteressionUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.tutorabc.com/aspx/reservationapi/reservationService/entersession?clientSn=%@", clientSn]];
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithURL:enteressionUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"enter session:%@", json);
                //                [[Crashlytics sharedInstance] setObjectValue:json forKey:@"enter session"];
                
                id classInfo = json[@"result"][@"classInfo"];
                if (classInfo != [NSNull null]) {
                    NSString *classType = classInfo[@"classType"];
                    NSString *compStatus = classInfo[@"compStatus"];
                    NSString *sessionRoomId = classInfo[@"sessionRoomId"];
                    NSString *sessionRoomRandStr = classInfo[@"randStr"];
                    NSString *sessionSn = classInfo[@"sessionSn"];
                    NSString *userSn = clientSn;
                    
                    NSURLComponents *url = [[NSURLComponents alloc] initWithString:@"http://www.tutormeet.com/tutormeetweb/login.do"];
                    
                    url.query = [@[[NSString stringWithFormat:@"action=%@", @"tutormeetLogin"],
                                   [NSString stringWithFormat:@"class_type=%@", classType],
                                   [NSString stringWithFormat:@"comp_status=%@", compStatus],
                                   [NSString stringWithFormat:@"session_room_id=%@", sessionRoomId],
                                   [NSString stringWithFormat:@"session_room_rand_str=%@", sessionRoomRandStr],
                                   [NSString stringWithFormat:@"session_sn=%@", sessionSn],
                                   [NSString stringWithFormat:@"user_sn=%@", userSn]]
                                 componentsJoinedByString:@"&"];
                    
                    NSLog(@"login url: %@", url);
                    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        NSLog(@"error: %@", error.localizedDescription);
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        //                        NSLog(@"login.do: %@", json);
                        //                        [[Crashlytics sharedInstance] setObjectValue:json forKey:@"login.do"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showInfoWithStatus:@"Login succeed! :)"];
                            if (completionHandler) completionHandler(json);
                        });
                        
                    }];
                    [dataTask resume];
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showInfoWithStatus:@"No classroom :("];
                        //                        if (completionHandler) completionHandler(nil);
                    });
                    NSLog(@"No class info");
                }
                
            }];
            [dataTask resume];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:@"Login Fail QQ"];
                //                if (completionHandler) completionHandler(nil);
            });
            NSLog(@"Login fail");
        }
    }];
    [dataTask resume];
    
}

-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewController];
}

#pragma makr - Autorotate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
