//
//  VASessionRoom1ViewController.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/19.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VASessionRoom1ViewController.h"

#import "ChatButton.h"
#import "TutorLog.h"
#import "DeviceUtility.h"
#import "PopoverMenuViewController.h"
#import "MessagesViewController.h"
#import "ITHelperViewController.h"
#import "TutormeetBroker.h"
#import "UILabel+CustomFont.h"

#import <WYPopoverController.h>
#import <WYStoryboardPopoverSegue.h>
#import <JSQMessage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <AlertView/AlertView.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VAMessagesViewController.h"

#import "VAVideoView.h"
#import "VAMessagesView.h"
#import "VAVolumeView.h"

#import "IQKeyboardManager.h"
#import "AppDelegate.h"

#import "VATool.h"

#define kDefaultUserVolumeFactor 0.5

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface VASessionRoom1ViewController () <LiveSessionDelegate, UIActionSheetDelegate, VAVolumeViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isDemo;

// View
@property (nonatomic, strong) VAVideoView *videoView;
@property (nonatomic, strong) UIView *materialView;
@property (nonatomic, strong) UIView *volumeView;
@property (nonatomic, strong) UIView *chatView;
@property (nonatomic, strong) UIView *exchangeView;
@property (nonatomic, strong) UIView *helpView;
@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) VAMessagesView *messagesView;
@property (nonatomic, strong) VAVolumeView *vaVolumeView;

@property (nonatomic, strong) AlertView *alert;

@property (nonatomic, strong) NSMutableArray *chatMessages;
@property (nonatomic, strong) NSMutableArray *helperMessages;
@property (nonatomic, assign) NSUInteger newHelpMessageCount;

@property (nonatomic, strong) LiveSession *session;

@property (nonatomic, assign) BOOL isLobbySession;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;

@property (nonatomic, strong) VAMessagesViewController *messenger;

// Session
@property (nonatomic, assign) BOOL needToRestartSession;

@property (nonatomic, strong) NSString *anchor;
@property (nonatomic, strong) NSString *cohost;
@property (nonatomic, strong) NSString *coordinator;
@property (nonatomic, strong) NSString *consultant;
@property (nonatomic, strong) NSSet *players;
@property (nonatomic, strong) NSArray *helperResponses;

// Control VideoView's visibility
@property(nonatomic, assign) int videoFps;
@property(nonatomic, assign) int videoDisabledByTutorConsole;

@property (nonatomic, strong) NSArray *helpActionSheetTitles;

@property (nonatomic, assign) int totalPage;
@property (nonatomic, assign) int currentPage;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIButton *showMaterialButton;
@property (nonatomic, strong) UIButton *showConsulantButton;
@property (nonatomic, strong) UIButton *materialPrevButton;
@property (nonatomic, strong) UIButton *materialNextButton;
@property (nonatomic, strong) UILabel *numberOfNewMessagesLabel;
@property (nonatomic, strong) UILabel *numberOfNewMessagesLabel2;
@property (nonatomic, strong) UILabel *numberOfHelpMessagesLabel;
@property (nonatomic, strong) UILabel *pageNumberLabel;
@property (nonatomic, assign) int numberOfNewMessages;
@property (nonatomic, assign) int numberOfHelpMessages;

@property (nonatomic, assign) BOOL hasShowChatView;
@property (nonatomic, assign) BOOL hasShowVolumeView;
@property (nonatomic, assign) BOOL showMaterial;
@property (nonatomic, assign) BOOL showConsulant;

@property (nonatomic, strong) UIAlertView *exitAlertView;
@property (nonatomic, strong) UIAlertView *evaluateAlertView;

@end

@implementation VASessionRoom1ViewController

@synthesize videoView, materialView, helpButton, volumeView, chatView, exchangeView, messagesView, vaVolumeView, bottomView, showMaterialButton, materialPrevButton, materialNextButton, numberOfNewMessagesLabel, numberOfNewMessagesLabel2, numberOfHelpMessagesLabel, rightView, showConsulantButton, showConsulant, exitAlertView, evaluateAlertView, pageNumberLabel, helpView;

- (instancetype)initWithClassInfo:(NSDictionary * _Nonnull)classInfo
                           isDemo:(BOOL)isDemo {
    self = [self init];
    if (self) {
        self.classInfo = classInfo;
        self.isDemo = isDemo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = RGBCOLOR(247, 248, 249, 1);
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBarHidden = YES;
    
    self.showMaterial = NO;
    self.showConsulant = YES;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(stopButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoView = [[VAVideoView alloc] init];
    self.videoView.contentMode = UIViewContentModeScaleAspectFill;
    self.videoView.layer.masksToBounds = YES;
    self.videoView.moveable = NO;
    
    self.materialView = [[UIView alloc] init];
    
    [self.view addSubview:self.materialView];
    [self.view addSubview:self.videoView];
    
    self.helpView = [[UIView alloc] init];
    helpView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:helpView];
    [helpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.width.equalTo(@(60));
        make.height.equalTo(@(20));
    }];
    
    UIView *helpCoverView = [UIView new];
    helpCoverView.backgroundColor = [UIColor darkGrayColor];
    helpCoverView.alpha = 0.6;
    helpCoverView.layer.cornerRadius = 10;
    
    [helpView addSubview:helpCoverView];
    [helpCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(helpView);
        make.height.equalTo(helpView);
        make.center.equalTo(helpView);
    }];
    
    self.helpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [helpButton setTitle:@"小帮手" forState:UIControlStateNormal];
    [helpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    helpButton.titleLabel.font = DEFAULT_FONT(14);
    //    [helpButton addTarget:self action:@selector(showHelpActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [helpButton addTarget:self action:@selector(showChatView:) forControlEvents:UIControlEventTouchUpInside];
    helpButton.tag = ChatMessageTypeIT;
    [self.helpView addSubview:helpButton];
    
    [helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(helpView);
    }];
    
    self.volumeView = [UIView new];
    volumeView.backgroundColor = [UIColor clearColor];
    volumeView.contentMode = UIViewContentModeCenter;
    volumeView.layer.cornerRadius = 27;
    volumeView.layer.masksToBounds = YES;
    //    volumeView.hidden = YES;
    
    self.chatView = [UIView new];
    chatView.backgroundColor = [UIColor clearColor];
    chatView.contentMode = UIViewContentModeCenter;
    chatView.layer.cornerRadius = 27;
    chatView.layer.masksToBounds = YES;
    
    self.exchangeView = [UIView new];
    exchangeView.backgroundColor = [UIColor clearColor];
    exchangeView.contentMode = UIViewContentModeCenter;
    exchangeView.layer.cornerRadius = 27;
    exchangeView.layer.masksToBounds = YES;
    
    [self.view addSubview:volumeView];
    [self.view addSubview:chatView];
    [self.view addSubview:exchangeView];
    
    UIView *volumeCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    volumeCoverView.backgroundColor = [UIColor blackColor];
    volumeCoverView.alpha = 0.2;
    
    UIView *chatCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    chatCoverView.backgroundColor = [UIColor blackColor];
    chatCoverView.alpha = 0.2;
    
    UIView *exchangeCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    exchangeCoverView.backgroundColor = [UIColor blackColor];
    exchangeCoverView.alpha = 0.2;
    
    [volumeView addSubview:volumeCoverView];
    [chatView addSubview:chatCoverView];
    [exchangeView addSubview:exchangeCoverView];
    
    UIButton *volumeButton = [self generateCustomButtonWithImageName:@"SessionRoomMemberVolume" action:@selector(showVolumeView)];
    UIButton *chatButton = [self generateCustomButtonWithImageName:@"SessionRoomChat" action:@selector(showChatView:)];
    chatButton.tag = ChatMessageTypeOther;
    
    UIButton *exchangeButton = [self generateCustomButtonWithImageName:@"SessionRoomExchange" action:@selector(rotateScreen)];
    
    [volumeView addSubview:volumeButton];
    [chatView addSubview:chatButton];
    [exchangeView addSubview:exchangeButton];
    
    self.videoView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
//    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view);
//        make.top.equalTo(self.view);
//        make.width.equalTo(self.view);
//        make.height.equalTo(self.view);
//    }];
    
    [self.materialView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view.bottom);
        make.width.equalTo(self.view);
        make.height.equalTo(@(kScreenHeight - videoView.bounds.size.height));
    }];
    
    [chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(54));
        make.height.equalTo(@(54));
        if (volumeView.hidden)
            make.centerX.equalTo(self.view.centerX).offset(-40);
        else
            make.centerX.equalTo(self.view);
        
        make.bottom.equalTo(self.view.bottom).offset(-20);
    }];
    
    [volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(chatView);
        make.height.equalTo(chatView);
        make.centerY.equalTo(chatView);
        make.right.equalTo(chatView.left).offset(-15);
    }];
    
    [exchangeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(chatView);
        make.height.equalTo(chatView);
        make.centerY.equalTo(chatView);
        if (volumeView.hidden)
            make.centerX.equalTo(self.view.centerX).offset(-40);
        else
            make.left.equalTo(chatView.right).offset(15);
    }];
    
    [chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(chatView);
        make.height.equalTo(chatView);
        make.top.equalTo(chatView).offset(0);
        make.left.equalTo(chatView).offset(0);
    }];
    
    [volumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(volumeView);
        make.height.equalTo(volumeView);
        make.top.equalTo(volumeView).offset(0);
        make.left.equalTo(volumeView).offset(0);
    }];
    
    [exchangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(exchangeView);
        make.height.equalTo(exchangeView);
        make.top.equalTo(exchangeView).offset(0);
        make.left.equalTo(exchangeView).offset(0);
    }];
    
    UIView *exitView = [[UIView alloc] init];
    exitView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:exitView];
    [exitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.view).offset(20);
        make.width.equalTo(@(65));
        make.height.equalTo(@(20));
    }];
    
    UIView *exitCoverView = [UIView new];
    exitCoverView.backgroundColor = [UIColor darkGrayColor];
    exitCoverView.alpha = 0.6;
    exitCoverView.layer.cornerRadius = 10;
    
    [exitView addSubview:exitCoverView];
    [exitCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(exitView);
        make.height.equalTo(exitView);
        make.center.equalTo(exitView);
    }];
    
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [exitButton setImage:[UIImage imageNamed:@"SessionRoomExit"] forState:UIControlStateNormal];
    [exitButton setTitle:@"退出" forState:UIControlStateNormal];
    exitButton.titleLabel.textColor = [UIColor whiteColor];
    exitButton.titleLabel.font = DEFAULT_FONT(14);
    exitButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [exitButton addTarget:self action:@selector(confirmExitSessionRoom) forControlEvents:UIControlEventTouchUpInside];
    [exitView addSubview:exitButton];
    [exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(exitView);
        make.width.equalTo(@(65));
    }];
    
    // Init session
    [self initSession];
    
    self.materialPrevButton = [self generateCustomButtonWithImageName:@"SessionRoomMaterialPrev" action:@selector(pagePrevPressed)];
    self.materialNextButton = [self generateCustomButtonWithImageName:@"SessionRoomMaterialNext" action:@selector(pageNextPressed)];
    [materialView addSubview:materialPrevButton];
    [materialView addSubview:materialNextButton];
    
    [materialPrevButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(materialView);
        make.left.equalTo(materialView.left).offset(20);
    }];
    
    [materialNextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(materialView);
        make.right.equalTo(materialView.right).offset(-20);
    }];
    
    UIView *pageNumberView = [[UIView alloc] init];
    pageNumberView.backgroundColor = [UIColor clearColor];
    pageNumberView.layer.cornerRadius = 10;
    
    UIView *coverView = [UIView new];
    coverView.backgroundColor = [UIColor darkGrayColor];
    coverView.alpha = 0.5;
    coverView.layer.cornerRadius = 10;
    
    [pageNumberView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(pageNumberView);
        make.height.equalTo(pageNumberView);
        make.center.equalTo(pageNumberView);
    }];
    
    self.pageNumberLabel = [[UILabel alloc] init];//[VATool getLabelWithTextString:[NSString stringWithFormat:@"%d/%d", self.currentPage, self.totalPage] fontSize:13 textColor:[UIColor whiteColor] sapce:0 bold:NO];
    self.pageNumberLabel.text = [NSString stringWithFormat:@"%d/%d", self.currentPage, self.totalPage];
    self.pageNumberLabel.font = DEFAULT_FONT(13);
    self.pageNumberLabel.textColor = [UIColor whiteColor];
    
    [pageNumberView addSubview:pageNumberLabel];
    
    [pageNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(pageNumberView);
    }];
    
    [materialView addSubview:pageNumberView];
    [pageNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(40));
        make.height.equalTo(@(20));
        make.centerX.equalTo(materialView);
        make.bottom.equalTo(materialView).offset(-20);
    }];
    
    self.numberOfHelpMessagesLabel = [[UILabel alloc] init];
    numberOfHelpMessagesLabel.backgroundColor = [UIColor redColor];
    numberOfHelpMessagesLabel.textAlignment = NSTextAlignmentCenter;
    numberOfHelpMessagesLabel.layer.cornerRadius = 10;
    numberOfHelpMessagesLabel.layer.masksToBounds = YES;
    numberOfHelpMessagesLabel.hidden = YES;
    numberOfHelpMessagesLabel.font = DEFAULT_FONT(11);
    numberOfHelpMessagesLabel.textColor = [UIColor whiteColor];
    NSString *str1 = [NSString stringWithFormat:@"%d", self.numberOfHelpMessages];
    if (self.numberOfHelpMessages > 99)
        str1 = @"...";
    numberOfHelpMessagesLabel.text = str1;
    
    [helpButton addSubview:numberOfHelpMessagesLabel];
    
    [numberOfHelpMessagesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
        make.centerY.equalTo(helpButton.top).offset(7);
        make.centerX.equalTo(helpButton.right);
    }];
    
    // Add Session Log
    NSAssert(self.classInfo, @"Class info should not to be nil");
    NSString *sessionSn = self.classInfo[@"sessionSn"];
    NSString *userSn = self.classInfo[@"clientSn"];
    NSString *userType = @"1"; // TODO: get user type from some API
    NSString *compStatus = self.classInfo[@"compStatus"];
    NSString *server = self.classInfo[@"server"];
    
    [TutormeetBroker addSessionLogWithSessionSn:sessionSn
                                         userSn:userSn
                                       userType:userType
                                         server:server
                                     compStatus:compStatus
                                     completion:^(NSData * data, NSURLResponse * response, NSError * error) {
                                         
                                         if (!error) {
                                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                             NSLog(@"Add Session Log done,\njson:%@\n res: %@", json, response);
                                         } else {
                                             NSLog(@"Add Session Log error \n error: %@", error);
                                         }
                                         
                                     }];
    [TutormeetBroker presentClassWithSessionSn:sessionSn userType:userType userSn:userSn compStatus:compStatus completion:^(NSData * _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"Present class user.do done,\njson:%@\n res: %@", json, response);
        } else {
            NSLog(@"Present class user.do error \n error: %@", error);
        }
    }];
    
    self.messenger = [[VAMessagesViewController alloc] init];
    
    self.chatMessages = [NSMutableArray array];
    self.helperMessages = [NSMutableArray array];
    
    self.helpActionSheetTitles = @[NSLocalizedString(@"There is communication noise", nil),
                                   NSLocalizedString(@"There is communication delay", nil),
                                   NSLocalizedString(@"Consultant is not in classroom", nil),
                                   NSLocalizedString(@"Consultant can't hear me", nil),
                                   NSLocalizedString(@"Can't hear consultant", nil),
                                   NSLocalizedString(@"Can't hear classmates", nil),
                                   NSLocalizedString(@"Consultant sounds very low", nil),
                                   NSLocalizedString(@"Can't see material", nil),
                                   NSLocalizedString(@"Ask IT to contact with me", nil),
                                   NSLocalizedString(@"Communication issue, please contact me later", nil),
                                   NSLocalizedString(@"Consultant issue, please contact me later", nil),
                                   NSLocalizedString(@"Material issue, please contact me later", nil),];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(messageViewRemoveFromSuperView) name:kMessageViewRemoveNotification object:nil];
}

- (void)generateBottomView
{
    [bottomView removeFromSuperview];
    // bottom view start
    self.bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = RGBCOLOR(0, 0, 0, 0.7);
    [bottomView addSubview:coverView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@(49));
        make.left.equalTo(self.view);
        
        if (self.showMaterial)
            make.bottom.equalTo(self.materialView.top);
        else
            make.bottom.equalTo(self.view.bottom);
    }];
    
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(bottomView);
        make.height.equalTo(bottomView);
        make.center.equalTo(bottomView);
    }];
    
    UIButton *volume2Button = [self generateCustomButtonWithImageName:@"SessionRoomMemberVolume" action:@selector(showVolumeView)];
    UIButton *chat2Button = [self generateCustomButtonWithImageName:@"SessionRoomChat" action:@selector(showChatView:)];
    chat2Button.tag = ChatMessageTypeOther;
    UIButton *exchange2Button = [self generateCustomButtonWithImageName:@"SessionRoomExchange" action:@selector(rotateScreen)];
    NSString *showMaterialImageName = @"";
    if (self.showMaterial)
        showMaterialImageName = @"SessionRoomDown";
    else
        showMaterialImageName = @"SessionRoomUp";
    
    self.showMaterialButton = [self generateCustomButtonWithImageName:showMaterialImageName action:@selector(showMaterialView)];
    
    [bottomView addSubview:chat2Button];
    [bottomView addSubview:showMaterialButton];
    [bottomView addSubview:exchange2Button];
    
    self.numberOfNewMessagesLabel = [[UILabel alloc] init];
    numberOfNewMessagesLabel.backgroundColor = [UIColor redColor];
    numberOfNewMessagesLabel.textAlignment = NSTextAlignmentCenter;
    numberOfNewMessagesLabel.layer.cornerRadius = 10;
    numberOfNewMessagesLabel.layer.masksToBounds = YES;
    numberOfNewMessagesLabel.hidden = self.numberOfNewMessages > 0 ? NO : YES;
    numberOfNewMessagesLabel.font = DEFAULT_FONT(11);
    numberOfNewMessagesLabel.textColor = [UIColor whiteColor];
    NSString *str = [NSString stringWithFormat:@"%d", self.numberOfNewMessages];
    if (self.numberOfNewMessages > 99)
        str = @"...";
    numberOfNewMessagesLabel.text = str;
    
    [bottomView addSubview:numberOfNewMessagesLabel];
    
    // 大会堂
    if (self.isLobbySession) {
        [showMaterialButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(bottomView);
        }];
        
        [chat2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomView);
            make.centerX.equalTo(bottomView.left).offset(kScreenWidth / 4);
        }];
        
        [exchange2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomView);
            make.centerX.equalTo(bottomView.left).offset(kScreenWidth * 3 / 4);
        }];
    }
    // 小班制
    else {
        [bottomView addSubview:volume2Button];
        
        [volume2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bottomView.left).offset(kScreenWidth / 5);
            make.centerY.equalTo(bottomView);
        }];
        
        [chat2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bottomView.left).offset(kScreenWidth * 2 / 5);
            make.centerY.equalTo(bottomView);
        }];
        
        [showMaterialButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bottomView.left).offset(kScreenWidth * 3 / 5);
            make.centerY.equalTo(bottomView);
        }];
        
        [exchange2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bottomView.left).offset(kScreenWidth * 4 / 5);
            make.centerY.equalTo(bottomView);
        }];
    }
    
    [numberOfNewMessagesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(20));
        make.width.equalTo(@(20));
        make.centerY.equalTo(chat2Button.top);
        make.centerX.equalTo(chat2Button.centerX).offset(15);
    }];

}

- (void)generateRightView
{
    [self.rightView removeFromSuperview];
    self.rightView = [[UIView alloc] init];
    rightView.backgroundColor = [UIColor clearColor];
    rightView.hidden = YES;
    [self.view addSubview:rightView];
    
    UIView *coverView2 = [[UIView alloc] init];
    coverView2.backgroundColor = RGBCOLOR(0, 0, 0, 0.7);
    [rightView addSubview:coverView2];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(49));
        make.height.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view.bottom);
    }];
    
    [coverView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(rightView);
        make.height.equalTo(rightView);
        make.center.equalTo(rightView);
    }];
    
    UIButton *volume2Button = [self generateCustomButtonWithImageName:@"SessionRoomMemberVolume" action:@selector(showVolumeView)];
    UIButton *chat2Button = [self generateCustomButtonWithImageName:@"SessionRoomChat" action:@selector(showChatView:)];
    chat2Button.tag = ChatMessageTypeOther;
    UIButton *exchange2Button = [self generateCustomButtonWithImageName:@"SessionRoomExchangeLandspace" action:@selector(rotateScreen)];
    self.showConsulantButton = [self generateCustomButtonWithImageName:@"SessionRoomTeacher" action:@selector(showConsulantView)];
    
    [rightView addSubview:chat2Button];
    [rightView addSubview:showConsulantButton];
    [rightView addSubview:exchange2Button];
    
    self.numberOfNewMessagesLabel2 = [[UILabel alloc] init];
    numberOfNewMessagesLabel2.backgroundColor = [UIColor redColor];
    numberOfNewMessagesLabel2.textAlignment = NSTextAlignmentCenter;
    numberOfNewMessagesLabel2.layer.cornerRadius = 10;
    numberOfNewMessagesLabel2.layer.masksToBounds = YES;
    numberOfNewMessagesLabel2.hidden = self.numberOfNewMessages > 0 ? NO : YES;
    numberOfNewMessagesLabel2.font = DEFAULT_FONT(11);
    numberOfNewMessagesLabel2.textColor = [UIColor whiteColor];
    NSString *str = [NSString stringWithFormat:@"%d", self.numberOfNewMessages];
    if (self.numberOfNewMessages > 99)
        str = @"...";
    numberOfNewMessagesLabel2.text = str;
    
    [rightView addSubview:numberOfNewMessagesLabel2];
    
    // 大会堂
    if (self.isLobbySession) {
        [showConsulantButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(rightView);
        }];
        
        [chat2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(rightView.top).offset(kScreenHeight / 4);
            make.centerX.equalTo(rightView);
        }];
        
        [exchange2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(rightView.top).offset(kScreenHeight * 3 / 4);
            make.centerX.equalTo(rightView);
        }];
    }
    // 小班制
    else {
        [rightView addSubview:volume2Button];
        
        [volume2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(rightView);
            make.centerY.equalTo(rightView.top).offset(kScreenHeight / 5);
        }];
        
        [chat2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(rightView);
            make.centerY.equalTo(rightView.top).offset(kScreenHeight * 2 / 5);
        }];
        
        [showConsulantButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(rightView);
            make.centerY.equalTo(rightView.top).offset(kScreenHeight * 3 / 5);
        }];
        
        [exchange2Button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(rightView);
            make.centerY.equalTo(rightView.top).offset(kScreenHeight * 4 / 5);
        }];
    }
    
    [numberOfNewMessagesLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(20));
        make.width.equalTo(@(20));
        make.centerY.equalTo(chat2Button.top);
        make.centerX.equalTo(chat2Button.centerX).offset(15);
    }];
}

- (UIButton *)generateCustomButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    button.contentMode = UIViewContentModeCenter;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Add KVO
    [self addKeyValueObserver];
    
    // Start session
    [self.session startSession];
    
    if (!self.isLobbySession) {
        [self openMicrophone];
    } else {
        //        self.micButton.hidden = YES;
        //        self.micVolume.hidden = YES;
    }
    
    // Check isDemo session
    //    if (self.isDemo) {
    //        self.prevPageButton.enabled = NO;
    //        self.nextPageButton.enabled = NO;
    //    }
    
    //    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Disable screen lock
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Check intro
    //    BOOL isTutorialShowed = [[NSUserDefaults standardUserDefaults] stringForKey:kIsTutorialShowed];
    //    if (!isTutorialShowed) {
    //        [self showTutorial:self.item5];
    //    }
    
    // Observe screen lock
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnteredBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMemoryWarn:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTermination:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    
    [self.session startSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop session
    self.session.delegate = nil;
    [self.session stopSession];
    [_recorder stop];
    [_levelTimer invalidate];
    _levelTimer = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // Remove Manual
    //    [self.tutorialView removeFromSuperview];
    
    // Remove KVO
    [self _removeKeyValueObserver];
    
    // Remove Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)messageViewRemoveFromSuperView
{
    self.hasShowChatView = NO;
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        self.bottomView.hidden = NO;
    }
}

#pragma mark - UIButton Events
- (void)showVolumeView
{
    if (self.hasShowVolumeView) {
        [self.vaVolumeView removeFromSuperview];
        self.hasShowVolumeView = NO;
        return;
    }
    
    [self.messagesView removeFromSuperview];
    self.hasShowVolumeView = YES;
    
    self.vaVolumeView = [[VAVolumeView alloc] init];
    vaVolumeView.delegate = self;
    vaVolumeView.session = self.session;
    
    NSArray *arr;
    if (!self.isLobbySession) {
        arr = self.consultant.length?
        [@[self.session.shortUserName, _consultant] arrayByAddingObjectsFromArray:self.players.allObjects]:
        [@[self.session.shortUserName] arrayByAddingObjectsFromArray:self.players.allObjects];
    } else {
        arr = self.consultant.length? @[_consultant]: @[];
    }
    
    vaVolumeView.volumeArray = arr;
    
    [self.view addSubview:vaVolumeView];
    
    [vaVolumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft | self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            make.width.equalTo(@(kScreenWidth - 49));
        }
        else
            make.width.equalTo(self.view);
        make.height.equalTo(self.view);
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);

    }];
}

- (void)showChatView:(UIControl *)sender
{
    if (self.hasShowChatView) {
        [self.messagesView removeFromSuperview];
        self.hasShowChatView = NO;
        return;
    }
    
    [self.vaVolumeView removeFromSuperview];
    int chatMessageType = [[NSString stringWithFormat:@"%ld", (long)sender.tag] intValue];
    self.messagesView = [[VAMessagesView alloc] initWithMessageType:chatMessageType];
    self.messagesView.messages = (chatMessageType == ChatMessageTypeIT) ? [self.helperMessages mutableCopy] : [self.chatMessages mutableCopy];
    self.messagesView.session = self.session;
    self.messagesView.consultantName = self.consultant;
    
    //    self.messagesView.chatMessageType = chatMessageType;
    
    [self.view addSubview:messagesView];
    [messagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft | self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            make.width.equalTo(@(kScreenWidth - 49));
        }
        else
            make.width.equalTo(self.view);
        make.height.equalTo(self.view);
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    self.hasShowChatView = YES;
    
    if (chatMessageType == ChatMessageTypeIT) {
        numberOfHelpMessagesLabel.hidden = YES;
        numberOfHelpMessagesLabel.text = @"";
        self.numberOfHelpMessages = 0;
    } else {
        numberOfNewMessagesLabel.hidden = YES;
        numberOfNewMessagesLabel.text = @"";
        numberOfNewMessagesLabel2.hidden = YES;
        numberOfNewMessagesLabel2.text = @"";
        self.numberOfNewMessages = 0;
    }
}

- (void)rotateScreen
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        [currentDevice setValue:[NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [currentDevice setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
}

- (void)showMaterialView
{
    self.showMaterial = !self.showMaterial;
    
    [self handleMaterialView];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showConsulantView
{
    self.showConsulant = !self.showConsulant;
    
    if (showConsulant) {
        videoView.hidden = NO;
        [showConsulantButton setImage:[UIImage imageNamed:@"SessionRoomTeacher"] forState:UIControlStateNormal];
    }
    else {
        videoView.hidden = YES;
        [showConsulantButton setImage:[UIImage imageNamed:@"SessionRoomNoneTeacher"] forState:UIControlStateNormal];
    }
}

- (void)showHelpActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取 消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    for (NSString *str in _helpActionSheetTitles) {
        [actionSheet addButtonWithTitle:str];
    }
    
    [actionSheet showInView:self.view];
}

- (void)handleMaterialView
{
    if (self.showMaterial) {
//        [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(self.view);
//            make.height.equalTo(@(self.view.bounds.size.height / 2));
//            make.top.equalTo(self.view);
//            make.left.equalTo(self.view);
//        }];
        
        self.videoView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight / 2);
        
        [self.materialView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(@(kScreenHeight / 2));
            make.left.equalTo(self.view);
            make.bottom.equalTo(self.view.bottom);
        }];
        
        [bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(@(50));
            make.left.equalTo(self.view);
            make.bottom.equalTo(self.materialView.top);
        }];
        
        [showMaterialButton setImage:[UIImage imageNamed:@"SessionRoomDown"] forState:UIControlStateNormal];
    }
    else {
//        [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(self.view);
//            make.height.equalTo(self.view);
//            make.top.equalTo(self.view);
//            make.left.equalTo(self.view);
//        }];
        
        self.videoView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        
        [self.materialView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.view.bottom);
            make.width.equalTo(self.view);
            make.height.equalTo(@(kScreenHeight - videoView.bounds.size.height));
        }];
        
        [bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.equalTo(@(50));
            make.left.equalTo(self.view);
            make.bottom.equalTo(self.view.bottom);
        }];
        
        [showMaterialButton setImage:[UIImage imageNamed:@"SessionRoomUp"] forState:UIControlStateNormal];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex====== %ld", (long)buttonIndex);
    
    if (buttonIndex != 0) {
        [self.session sendHelpMessage:[_helpActionSheetTitles objectAtIndex:buttonIndex - 1] msgIdx:[NSNumber numberWithInteger:buttonIndex - 1]];
    }
}

#pragma mark - Background and Foreground
- (void)handleEnteredForeground:(id)sender {
    [self initSession];
    [self.session startSession];
}

- (void)handleEnteredBackground:(id)sender {
    self.session.delegate = nil;
    [self.session stopSession];
}

- (void)handleMemoryWarn:(id)sender {
    NSLog(@"memory warn");
}

- (void)handleTermination:(id)sender {
    NSLog(@"Termination");
}

#pragma mark - Session About
- (void)initSession {
    // Reset chat view
    [self.helperMessages removeAllObjects];
    //    [self.itHelper finishReceivingMessage];
    //    [self.chatMessages removeAllObjects];
    //    [self.messenger finishReceivingMessage];
    
    // Stop session
    [self.session stopSession];
    
    // Reset Session info
    if (!self.session) {
        self.session = [[LiveSession alloc] initSessionWithClassInfo:self.classInfo delegate:self streamerView:nil consultantView:self.videoView whiteboardView:self.materialView];
        self.session.defaultUserVolumeFactor = kDefaultUserVolumeFactor;
    }
    
    self.session.delegate = self;
}

- (BOOL)isLobbySession {
    NSLog(@"%@", self.classInfo[@"lobbySession"]);
    return [@"true" isEqualToString:self.classInfo[@"lobbySession"]] || [@"Y" isEqualToString:self.classInfo[@"lobbySession"]];
}

- (void)openMicrophone {
    
    NSError *error;
    if (!_recorder) {
        // empty URL
        NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
        
        // define settings for AVAudioRecorder
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat: 44100.0],                      AVSampleRateKey,
                                  [NSNumber numberWithInt: kAudioFormatAppleLossless],      AVFormatIDKey,
                                  [NSNumber numberWithInt:1],                               AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt:AVAudioQualityMax],               AVEncoderAudioQualityKey,
                                  nil];
        
        // init and apply settings
        _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        
        // This here is what you are missing, without it the mic input will work in the simulator,
        // but not on a device.
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                            error:nil];
    }
    
    if (error) {
        
        NSLog(@"%@", error.description);
        
    } else {
        
        if (!_recorder.isRecording) {
            [_recorder prepareToRecord];
            _recorder.meteringEnabled = YES;
            _levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
            [_recorder record];
            
            // Update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:@"Mic On"];
                //                [self.micButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_mike_default"] forState:UIControlStateNormal];
            });
        }
    }
    [self.session setMicrophoneMute:NO];
}

- (void)closeMicrophone {
    
    // Stop audio service
    if (_recorder && _recorder.isRecording) {
        
        [_recorder stop];
        // Update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:@"Mic Off"];
            //            [self.micButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_mike_disable"] forState:UIControlStateNormal];
        });
    }
    [self.session setMicrophoneMute:YES];
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [_recorder updateMeters];
    
    float peakPowerForChannel = [_recorder peakPowerForChannel:0] > 0? 1: pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    
    NSString *imageName = peakPowerForChannel * 17 < 1?
    @"sessionroom_displays_volume_default":
    [NSString stringWithFormat:@"sessionroom_displays_volume_%02.0f", peakPowerForChannel * 17];
    
    //    DDLogDebug(@"Peak input: %.2f, %@", peakPowerForChannel, imageName);
    
    //    self.micVolume.image = [UIImage imageNamed:imageName];
}

#pragma mark - Button Events
- (void)confirmExitSessionRoom
{
    NSString *sessionEndTime = [self.classInfo objectForKey:@"sessionEndTime"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSDate *sessionEndDate = [dateFormatter dateFromString:sessionEndTime];
    
    NSTimeInterval timeInterval = [sessionEndDate timeIntervalSinceNow];
    
    if (timeInterval > 0) {
        self.exitAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您是否要离开教室？" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        [exitAlertView show];
    } else {
        self.evaluateAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您是否要对本节课做出评价？" delegate:self cancelButtonTitle:@"去评价" otherButtonTitles:@"离开教室", nil];
        [evaluateAlertView show];
    }
}

- (void)exitSessionRoom
{
    [self onExitApp];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pagePrevPressed {
    if (self.currentPage > 0) {
        [self.session switchWhiteboardPage:self.currentPage - 1];
    }
}

- (void)pageNextPressed {
    if (self.currentPage < self.totalPage - 1) {
        [self.session switchWhiteboardPage:self.currentPage + 1];
    }
}

- (void)stopButtonPressed
{
    
}

- (void)showReloadAlert {
    __weak VASessionRoom1ViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.alert) return;
        weakSelf.alert = [AlertView showInfoWithTitle:NSLocalizedString(@"Tip", nil)
                                                 text:NSLocalizedString(@"Connection Fail", nil)];
        
        [weakSelf.alert.rightButton setTitle:@"重新載入" forState:UIControlStateNormal];
        weakSelf.alert.rightButtonAction = ^(AlertView *alert) {
            [self initSession];
            [self.session startSession];
            [alert dismissAll];
            weakSelf.alert = nil;
        };
    });
}

- (void)showAlreadyLoginAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        //        AlertView *alert = [AlertView showInfoWithTitle:NSLocalizedString(@"Tip", nil)
        //                                                   text:NSLocalizedString(@"Already login from other device", nil)];
        //
        //        [alert.rightButton setTitle:NSLocalizedString(@"Exit", nil) forState:UIControlStateNormal];
        //        alert.rightButtonAction = ^(AlertView *alert) {
        //            self.session.delegate = nil;
        //            [self.session stopSession];
        //            [alert dismissAll];
        //            [self dismissViewControllerAnimated:YES completion:nil];
        //            [[NSNotificationCenter defaultCenter] postNotificationName:UILiveSessionType1WillCloseNotification object:nil];
        //        };
        //        alert.rightButtonWidthConstraint.constant = alert.bounds.size.width;
        //        alert.leftButtonWidthConstraint.constant = 0.f;
        //        alert.rightButtonWidthConstraint.constant = 255.f;
    });
}

- (void)videoViewDoubleTapped
{
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        [videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@(100));
//            make.height.equalTo(@(100));
//            make.bottom.equalTo(self.view).offset(-15);
//            make.right.equalTo(rightView.left).offset(-15);
//        }];
        
        videoView.frame = CGRectMake(kScreenWidth - 100 - 50 - 15, kScreenHeight - 100 - 15, 100, 100);
        
//        videoView.frame = CGRectMake(self.view.bounds.size.width - rightView.bounds.size.width - 100 - 15, self.view.bounds.size.height - 100 - 15, 100, 100);
    }
}

- (void)updatePageIndex
{
    pageNumberLabel.text = [NSString stringWithFormat:@"%d/%d", self.currentPage + 1, self.totalPage];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView == exitAlertView)
            [self exitSessionRoom];
        else if (alertView == evaluateAlertView) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
            
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate navigateToEvaluatePage:[self.classInfo objectForKey:@"sessionSn"]];
        }
    }
    else if (buttonIndex == 1 && alertView == evaluateAlertView) {
        [self exitSessionRoom];
    }
}


#pragma mark - Session Delegate
- (void)onSessionStarted:(BOOL)success {
    DDLogDebug(@"onSessionStarted: %d", success);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    
    if (!success)
        [self showReloadAlert];
}

- (void)onSessionStopped {
    DDLogDebug(@"onSessionStopped");
    
    if (self.needToRestartSession) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            [self.session startSession];
        });
    }
}

- (void)onNoFrameGot:(NSString *)userName {
    [self.session reconnectUser:userName];
}

- (void)onAnchorChanged:(NSString *)anchor {
    DDLogDebug(@"onAnchorChanged: %@", anchor);
    self.anchor = anchor;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([kSessionRoleTypeCoordinator isEqualToString:anchor]) {
            self.consultant = self.coordinator;
            //            self.consultantNameLabel.text = [self.coordinator componentsSeparatedByString:@"~"].firstObject;
        } else if ([kSessionRoleTypeCohost isEqualToString:anchor]) {
            self.consultant = self.cohost;
            //            self.consultantNameLabel.text = [self.cohost componentsSeparatedByString:@"~"].firstObject;
        }
        //        self.messenger.consultantName = self.consultantNameLabel.text;
    });
}

- (void)onUserIn:(NSString *)userName role:(NSString *)role {
    DDLogDebug(@"onUserIn - userName:%@, role:%@", userName, role);
    if ([kSessionRoleTypeStudent isEqualToString:role] || [kSessionRoleTypeSales isEqualToString:role]) {
        NSArray *arr = [@[userName] arrayByAddingObjectsFromArray:self.players.allObjects];
        self.players = [NSSet setWithArray:arr];
        
    } else if ([kSessionRoleTypeCohost isEqualToString:role]) {
        
        self.cohost = userName;
        
    } else if ([kSessionRoleTypeCoordinator isEqualToString:role]) {
        
        self.coordinator = userName;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([kSessionRoleTypeCoordinator isEqualToString:self.session.anchor]) {
            self.consultant = self.coordinator;
            //            self.consultantNameLabel.text = [self.consultant componentsSeparatedByString:@"~"].firstObject;
        } else if ([kSessionRoleTypeCohost isEqualToString:self.session.anchor]) {
            self.consultant = self.cohost;
            //            self.consultantNameLabel.text = [self.consultant componentsSeparatedByString:@"~"].firstObject;
        }
        //        self.messenger.consultantName = self.consultantNameLabel.text;
    });
    
    if (self.consultant.length) {
        // Consultant in:
        // 1. Open microphone if it's not lobby session
        if (!self.isLobbySession) [self openMicrophone];
    }
}

- (void)onUserOut:(NSString *)userName {
    DDLogDebug(@"onUserOut - userName:%@", userName);
    
    if ([self.consultant isEqualToString:userName]) {
        // Consultant out:
        // 1. Hide video view
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.consultant isEqualToString:self.coordinator])
                self.coordinator = @"";
            else if ([self.consultant isEqualToString:self.cohost])
                self.cohost = @"";
            
            //            self.consultantNameLabel.text = @"";
            self.consultant = @"";
            //            self.messenger.consultantName = self.consultantNameLabel.text;
        });
        // 2. Close microphone if not lobby session
        if (!self.isLobbySession) [self closeMicrophone];
        
    } else {
        NSMutableSet *newPlayers = self.players.mutableCopy;
        [newPlayers removeObject:userName];
        self.players = newPlayers;
    }
}

- (void)onMessage:(NSArray *)messages {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (SessionChatMessage *msg in messages) {
            DDLogDebug(@"onMessage - userName:%@, Time:%@, message:%@, important:%d", msg.userName, msg.time, msg.message, msg.priority);
            
            NSString *senderId = msg.priority == SessionChatMessagePriority_High? self.session.shortUserName: msg.userName;
            if ([msg.userName rangeOfString:@"IT"].location != NSNotFound &&
                [msg.userName rangeOfString:@" to "].location != NSNotFound) {
                senderId = [msg.userName componentsSeparatedByString:@" to "].firstObject;
                JSQMessage *chatMessage = [JSQMessage messageWithSenderId:senderId
                                                              displayName:msg.userName
                                                                     text:msg.message];
                [self.helperMessages addObject:chatMessage];
                
                if (messagesView != nil && messagesView.chatMessageType == ChatMessageTypeIT) {
                    [self.messagesView receiveMessage:chatMessage];
                }
                
                self.numberOfHelpMessages = ++self.numberOfHelpMessages;
                //                self.itHelperButton.hidden = NO;
                //                if (!self.itHelperPopover.isPopoverVisible) _newHelpMessageCount++;
            } else {
                JSQMessage *chatMessage = [JSQMessage messageWithSenderId:senderId
                                                              displayName:msg.userName
                                                                     text:msg.message];
                [self.chatMessages addObject:chatMessage];
                
                if (messagesView != nil && messagesView.chatMessageType == ChatMessageTypeOther) {
                    [self.messagesView receiveMessage:chatMessage];
                }
                
                if (msg.priority == SessionChatMessagePriority_High) [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Message Sent", nil) maskType:SVProgressHUDMaskTypeBlack];
                
                self.numberOfNewMessages = ++self.numberOfNewMessages;
            }
            
            NSString *str1 = [NSString stringWithFormat:@"%d", self.numberOfHelpMessages];
            if (self.numberOfHelpMessages > 99)
                str1 = @"...";
            
            NSString *str2 = [NSString stringWithFormat:@"%d", self.numberOfNewMessages];
            if (self.numberOfNewMessages > 99)
                str2 = @"...";
            
            if (!self.hasShowChatView) {
                numberOfNewMessagesLabel.text = str2;
                numberOfNewMessagesLabel.hidden = self.numberOfNewMessages > 0 ? NO : YES;
                numberOfNewMessagesLabel2.text = str2;
                numberOfNewMessagesLabel2.hidden = self.numberOfNewMessages > 0 ? NO : YES;
                
                numberOfHelpMessagesLabel.text = str1;
                numberOfHelpMessagesLabel.hidden = self.numberOfHelpMessages > 0 ? NO : YES;
            }
            else if (self.hasShowChatView && self.messagesView.chatMessageType == ChatMessageTypeOther) {
                numberOfHelpMessagesLabel.text = str1;
                numberOfHelpMessagesLabel.hidden = self.numberOfHelpMessages > 0 ? NO : YES;
            }
            else {
                numberOfNewMessagesLabel.text = str2;
                numberOfNewMessagesLabel.hidden = self.numberOfNewMessages > 0 ? NO : YES;
                numberOfNewMessagesLabel2.text = str2;
                numberOfNewMessagesLabel2.hidden = self.numberOfNewMessages > 0 ? NO : YES;
            }
        }

        //        [self.messenger finishReceivingMessage];
        //        [self.itHelper finishReceivingMessage];
        
        //        [self updateNoticeBadge:self.itHelperButton withCount:_newHelpMessageCount];
    });
}

- (void)onConsultantLost:(NSString *)consultant {
    DDLogDebug(@"onConsultantLost");
    // Never seen it happen
}


- (void)onSendWaitMsg {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [self.chatMessages addObject:[JSQMessage messageWithSenderId:@""
//                                                         displayName:@""
//                                                                text:@"Dear customers: Please do not leave the classroom. Consultants are about to enter the classroom. Thank you for your patience."]];
//        [self.messenger finishSendingMessage];
//    });
    
}

- (void)onMicMute:(BOOL)mute {
    DDLogDebug(@"onMicMute: %@", @(mute));
    NSAssert(!self.isLobbySession, @"onMicMute is not availabe on lobby session");
    [self.session setMicrophoneMute:mute];
    if (mute) {
        [self closeMicrophone];
    } else {
        [self openMicrophone];
    }
}

// 0 ~ 1, request from server, upper layer needs to decide if need to setMicrophoneGain or not
- (void)onMicGainChanged:(float)vol {
    [self.session setMicrophoneGain:vol];
}

// request from server, upper layer needs to decide if need to disable video or not
- (void)onDisableVideo:(int)disable {
    self.videoDisabledByTutorConsole = disable;
}

// request from server, upper layer needs to decide if need to disable chat or not
- (void)onDisableChat:(int)disable {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messenger.inputToolbar setUserInteractionEnabled:!disable];
        [self.messenger.inputToolbar.contentView.rightBarButtonItem setTitleColor:disable ? UIColor.lightGrayColor : UIColorFromRGB(0x00C4EB)
                                                                         forState:UIControlStateDisabled];
    });
    
}

- (void)onHelpMessage:(NSNumber *)messageId status:(HelpMsgStatus)status {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (status) {
            case HelpMsgStatus_Done:
                self.helperResponses = [@[messageId] arrayByAddingObjectsFromArray:self.helperResponses];
                //                [self updateNoticeBadge:self.item4 withCount:self.helperResponses.count];
                DDLogDebug(@"Help msg status done... sending no for confirmation, %@", self.helperResponses);
                break;
                
            case HelpMsgStatus_Waiting:
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Message Sent", nil) maskType:(SVProgressHUDMaskTypeBlack)];
                break;
                
            case HelpMsgStatus_Closed:
                [SVProgressHUD showInfoWithStatus:@"Close"];
                break;
                
            case HelpMsgStatus_Processing:
                [SVProgressHUD showInfoWithStatus:@"Processing"];
                break;
                
            case HelpMsgStatus_RequireResponse:
                
            default: {
                NSString *displayName = [NSString stringWithFormat:@"IT~%@", messageId];
                NSString *text = [NSString stringWithFormat:@"onHelpMessage Status: %d", status];
                [self.helperMessages addObject:[JSQMessage messageWithSenderId:displayName displayName:displayName text:text]];
                //                [self.itHelper finishSendingMessage];
                break;
            }
        }
    });
    
}

// request from server, upper layer needs to decide if need to relogin or not
- (void)onRelogin {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
        self.needToRestartSession = YES;
        [self initSession];
    });
}

// request from server, upper layer needs to decide if need to show admin message or not
- (void)onAdminMessage:(NSString *)msg {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Understood", nil)
                                          otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
    
}

- (void)onExitApp {
    self.session.delegate = nil;
    [self.session stopSession];
//    [self showAlreadyLoginAlert];
}

- (void)onWhiteboardPageChanged:(int)pageIdx {
    self.currentPage = pageIdx;
    
    [self performSelectorOnMainThread:@selector(updatePageIndex) withObject:nil waitUntilDone:YES];
}

- (void)onWhiteboardTotalPages:(int)totalPages {
    self.totalPage = totalPages;
}

// The following onWhiteboard methods will be invoked if upper layer doesn't provide whiteboard view for Session
- (void)onWhiteboardResetWebPointer {
    
}

- (void)onWhiteboardResetWebMouse {
    
}

- (void)onWhiteboardWebPointerChange:(CGPoint)point {
    
}

- (void)onWhiteboardWebMouseChange:(CGPoint)point {
    
}

- (void)onWhiteboardObjectAdded:(WhiteboardObject *)wbObject {
    
}

- (void)onWhiteboardObjectUpdated:(WhiteboardObject *)wbObject {
    
}

- (void)onWhiteboardObjectRemoved:(int)objId {
    
}

- (void)onVideoFps:(int)fps {
    self.videoFps = fps;
    
    if (fps == 0)
        [self.session startSession];
}

- (void)onPositionChanged:(long long)position {
    
    //    if (position == self.lastPosition && !self.videoPlaceholder.hidden) self.timeoutCounter++;
    //
    //    if (self.timeoutCounter > kTimeoutInSeconds && self.consultant.length) {
    //        self.timeoutCounter = 0;
    //        //        dispatch_async(dispatch_get_main_queue(), ^{
    //        //            [SVProgressHUD showInfoWithStatus:@"A/V Loading..."];
    //        //        });
    //    }
    //
    //    self.lastPosition = position;
}

#pragma mark - KVO
- (void)addKeyValueObserver {
    [self addObserver:self forKeyPath:@"videoFps" options:0 context:nil];
    [self addObserver:self forKeyPath:@"videoDisabledByTutorConsole" options:0 context:nil];
}

- (void)_removeKeyValueObserver {
    [self removeObserver:self forKeyPath:@"videoFps"];
    [self removeObserver:self forKeyPath:@"videoDisabledByTutorConsole"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"videoDisabledByTutorConsole"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            if (self.videoDisabledByTutorConsole == 0 && !self.videoPlaceholder.hidden)
            //                self.videoView.hidden = NO;
            //            else
            //                self.videoView.hidden = YES;
        });
    }
}

#pragma mark - VAVolumeViewDelegate
- (void)didUpdateMicrophoneVolume:(UISlider *)slider {
    if (slider.value) {
        [self openMicrophone];
    } else {
        [self closeMicrophone];
    }
}

#pragma mark - Rotate
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"InterfaceOrientation: %ld", self.interfaceOrientation);
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait ||
        self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        //        [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.view);
        //            make.top.equalTo(self.view);
        //            make.width.equalTo(self.view);
        //            if (self.showMaterial)
        //                make.height.equalTo(@(self.view.bounds.size.height / 2));
        //            else
        //                make.height.equalTo(self.view);
        //        }];
        //
        //        [materialView mas_remakeConstraints:^(MASConstraintMaker *make) {
        //            make.left.equalTo(self.view);
        //            make.width.equalTo(self.view);
        //            make.height.equalTo(@(kScreenHeight - videoView.bounds.size.height));
        //            if (self.showMaterial)
        //                make.top.equalTo(videoView.bottom);
        //            else
        //                make.top.equalTo(self.view.bottom);
        //        }];
        
        [self handleMaterialView];
        
        [materialNextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(materialView);
            make.right.equalTo(materialView.right).offset(-20);
        }];
        
        [chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(54));
            make.height.equalTo(@(54));
            if (volumeView.hidden)
                make.centerX.equalTo(self.view.centerX).offset(-40);
            else
                make.centerX.equalTo(self.view);
            
            make.bottom.equalTo(self.view.bottom).offset(-20);
        }];
        
        [exchangeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(chatView);
            make.height.equalTo(chatView);
            make.centerY.equalTo(chatView);
            if (volumeView.hidden)
                make.centerX.equalTo(self.view.centerX).offset(40);
            else
                make.left.equalTo(chatView.right).offset(15);
        }];
        
        [volumeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(chatView);
            make.height.equalTo(chatView);
            make.centerY.equalTo(chatView);
            make.right.equalTo(chatView.left).offset(-15);
        }];
        
        [materialNextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(materialView);
            make.right.equalTo(materialView.right).offset(-20);
        }];
        
        [helpView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
            make.right.equalTo(self.view.right).offset(-20);
            make.width.equalTo(@(60));
            make.height.equalTo(@(20));
        }];
        
        [self generateBottomView];
        
        self.videoView.hidden = NO;
        self.videoView.moveable = NO;
        self.videoView.layer.cornerRadius = 0;
        self.videoView.layer.masksToBounds = YES;
        
        if (self.hasShowChatView) {
            [messagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self.view);
                make.height.equalTo(self.view);
                make.left.equalTo(self.view);
                make.top.equalTo(self.view);
            }];
            
            self.bottomView.hidden = YES;
        }
        else if (self.hasShowVolumeView) {
            [vaVolumeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self.view);
                make.height.equalTo(self.view);
                make.left.equalTo(self.view);
                make.top.equalTo(self.view);
            }];
            
            self.bottomView.hidden = YES;
        }
        else {
            self.bottomView.hidden = NO;
        }
        
        self.exchangeView.hidden = YES;
        self.chatView.hidden = YES;
        self.volumeView.hidden = YES;
        self.rightView.hidden = YES;
        
    } else {
        [exchangeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(chatView);
            make.height.equalTo(chatView);
            make.bottom.equalTo(self.view.bottom).offset(-15);
            make.right.equalTo(self.view).offset(-50);
        }];
        
        [chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(54));
            make.height.equalTo(@(54));
            make.centerX.equalTo(exchangeView);
            make.bottom.equalTo(exchangeView.top).offset(-10);
        }];
        
        [volumeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(chatView);
            make.height.equalTo(chatView);
            make.centerX.equalTo(exchangeView);
            make.bottom.equalTo(chatView.top).offset(-10);
        }];
        
        [materialView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(self.view);
        }];
        
        [materialNextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(materialView);
            make.right.equalTo(materialView.right).offset(-20 - 49);
        }];
        
        [self generateRightView];
        
        [helpView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
            make.right.equalTo(rightView.left).offset(-15);
            make.width.equalTo(@(60));
            make.height.equalTo(@(20));
        }];
        
//        [videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@(100));
//            make.height.equalTo(@(100));
//            make.bottom.equalTo(self.view).offset(-15);
//            make.right.equalTo(rightView.left).offset(-15);
//        }];
        
        int videoViewX = videoView.movedX;
        int videoViewY = videoView.movedY;
        
        if (videoViewX == 0 && videoViewY == 0) {
            videoViewX = kScreenWidth - 100 - 50 -15;
            videoViewY = kScreenHeight - 100 - 15;
        }
        
        videoView.frame = CGRectMake(videoViewX, videoViewY, 100, 100);
        
        if (self.hasShowChatView) {
            [messagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(kScreenWidth - 49));
                make.height.equalTo(self.view);
                make.left.equalTo(self.view);
                make.top.equalTo(self.view);
            }];
        }
        
        if (self.hasShowVolumeView) {
            [vaVolumeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(kScreenWidth - 49));
                make.height.equalTo(self.view);
                make.left.equalTo(self.view);
                make.top.equalTo(self.view);
            }];
        }
        
        self.videoView.moveable = YES;
        self.videoView.layer.cornerRadius = 50;
        self.videoView.layer.masksToBounds = YES;
        
        self.rightView.hidden = NO;
        self.bottomView.hidden = YES;
        self.chatView.hidden = YES;
        self.exchangeView.hidden = YES;
//        if (self.isLobbySession)
            self.volumeView.hidden = YES;
//        else
//            self.volumeView.hidden = NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoViewDoubleTapped)];
        tapGesture.numberOfTapsRequired = 2;
        
        [videoView addGestureRecognizer:tapGesture];
    }
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
