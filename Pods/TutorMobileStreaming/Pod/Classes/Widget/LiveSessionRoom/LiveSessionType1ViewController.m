//
//  LiveSessionType1ViewController.m
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/8/31.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "LiveSessionType1ViewController.h"

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

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define kDefaultUserVolumeFactor 0.5
#define kTranslateDuration 0.5                  // Translation duration of view
static int const kTimeoutInSeconds = 3;        // Show loading info if timestamp is not upda-to-date

static int const kVideoContainerLeftNormal = 14;
static int const kVideoContainerLeftHidden = 14 - 276 - 14;

static int const kVideoContainerTopNormal = 20;
static int const kVideoContainerTopHidden = 20 - 245;

static int const kVideoContainerLeftNormalForiPhone = 0;
static int const kVideoContainerLeftHiddenForiPhone = -165;

static int const kVideoContainerTopNormalForiPhone = 0;
static int const kVideoContainerTopHiddenForiPhone = -145;

static int const kPopoverTopMargin = 44;
static int const kPopoverBottomMargin = 44;
static int const kPopoverWidth = 360;

static int const kCountDownTimerDuration = 10;  // count down timer of talk to IT in 10 seconds

static NSString * const kIsTutorialShowed = @"LiveSessionType1ViewController.isTutorialShowed";
NSString *const _Nonnull UILiveSessionType1WillCloseNotification = @"UILiveSessionType1WillCloseNotification";

@interface LiveSessionType1ViewController () <WYPopoverControllerDelegate, LiveSessionDelegate, PopoverMenuDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *item1; //成員音量
@property (strong, nonatomic) IBOutlet UIBarButtonItem *item2; //我有話對客服說
@property (strong, nonatomic) IBOutlet UIBarButtonItem *item3; //我有話對顧問說
@property (strong, nonatomic) IBOutlet UIBarButtonItem *item4; //通知
@property (strong, nonatomic) IBOutlet UIBarButtonItem *item5; //簡介
@property (strong, nonatomic) IBOutlet UIBarButtonItem *item6; //Reload
@property (weak, nonatomic) IBOutlet UIView *videoPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *consultantNameLabel;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *whiteboardPlaceholder;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *itHelperButton;

@property (weak, nonatomic) IBOutlet UIView *materialView;

@property (weak, nonatomic) IBOutlet UIView *videoContainer;

@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *videoContainerLeft;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *videoContainerTop;

// Right-Bottom toolbar
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *micButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *micVolume;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *totoalPageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *prevPageButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *nextPageButton;

@property (weak, nonatomic) IBOutlet UIButton *zoomInButton;
@property (weak, nonatomic) IBOutlet UIButton *collapseButton;


@property (nonatomic, strong) LiveSession *session;

@property (nonatomic, strong) WYPopoverController *popover;

// IT Helper
@property (nonatomic, strong) WYPopoverController *itHelperPopover;
@property (nonatomic, strong) MessagesViewController *messenger;
@property (nonatomic, strong) ITHelperViewController *itHelper;
@property (nonatomic, strong) NSMutableArray *chatMessages;
@property (nonatomic, strong) NSMutableArray *helperMessages;
@property (nonatomic, assign) NSUInteger newHelpMessageCount;

@property (nonatomic, strong) NSString *anchor;
@property (nonatomic, strong) NSString *cohost;
@property (nonatomic, strong) NSString *coordinator;
@property (nonatomic, strong) NSString *consultant;
@property (nonatomic, strong) NSSet *players;
@property (nonatomic, strong) NSArray *helperResponses;


@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic, assign) double db;
@property (nonatomic, assign) NSUInteger lastPosition;
@property (nonatomic, assign) NSUInteger timeoutCounter;

@property (nonatomic, assign) BOOL isITHelperEnabled;
@property (nonatomic, assign) BOOL isConsultantHelperEnabled;
@property (nonatomic, assign) BOOL isDemo;

// Menu
@property (nonatomic, strong) NSArray *helpMsgMenu;

// Control VideoView's visibility
@property(nonatomic, assign) int videoFps;
@property(nonatomic, assign) int videoDisabledByTutorConsole;

// Intro
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIView *tutorialView;

// Control device's speaker volume
@property (nonatomic, strong) MPVolumeView *volumeView;

@property (nonatomic, strong) AlertView *alert;

// Session
@property (nonatomic, assign) BOOL needToRestartSession;

@end


@implementation LiveSessionType1ViewController

- (instancetype)init {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LiveSessionType1_iPad" bundle:nil];
    
    self = (LiveSessionType1ViewController *)[sb instantiateViewControllerWithIdentifier:@"LiveSessionType1ViewController"];
    
    if (self) {
        // your statement
        self.helpMsgMenu = @[NSLocalizedString(@"There is communication noise", nil),
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
    }
    return self;
}

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
    
    // Lock orientation for landscape
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
    
    self.navigationItem.rightBarButtonItems = @[self.item1, self.item2, self.item3, self.item4, self.item5, self.item6];
    self.navigationItem.leftBarButtonItem.image = [[UIImage imageNamed:@"sessionroom_btn_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sessionroom_logo"]];
    [[UILabel appearanceWhenContainedIn:self.class, nil] setSubstituteFontName:@"Montserrat-Regular"];
    
    self.videoView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //
        if ([obj isMemberOfClass:MessagesViewController.class]) {
            self.messenger = obj;
        }
    }];
    
    self.helperMessages = [NSMutableArray new];
    self.chatMessages = [NSMutableArray new];
    
    // Init session
    [self initSession];

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
    
    // Init volumeView
    self.volumeView = [[MPVolumeView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Add KVO
    [self _addKeyValueObserver];
    
    // Start session
    [self.session startSession];
    
    if (!self.isLobbySession) {
        [self openMicrophone];
    } else {
        self.micButton.hidden = YES;
        self.micVolume.hidden = YES;
    }
    
    // Check isDemo session
    if (self.isDemo) {
        self.prevPageButton.enabled = NO;
        self.nextPageButton.enabled = NO;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Disable screen lock
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Check intro
    BOOL isTutorialShowed = [[NSUserDefaults standardUserDefaults] stringForKey:kIsTutorialShowed];
    if (!isTutorialShowed) {
        [self showTutorial:self.item5];
    }
    
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
    [self.tutorialView removeFromSuperview];
    
    // Remove KVO
    [self _removeKeyValueObserver];
    
    // Remove Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
            self.consultantNameLabel.text = [self.coordinator componentsSeparatedByString:@"~"].firstObject;
        } else if ([kSessionRoleTypeCohost isEqualToString:anchor]) {
            self.consultant = self.cohost;
            self.consultantNameLabel.text = [self.cohost componentsSeparatedByString:@"~"].firstObject;
        }
        self.messenger.consultantName = self.consultantNameLabel.text;
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
            self.consultantNameLabel.text = [self.consultant componentsSeparatedByString:@"~"].firstObject;
        } else if ([kSessionRoleTypeCohost isEqualToString:self.session.anchor]) {
            self.consultant = self.cohost;
            self.consultantNameLabel.text = [self.consultant componentsSeparatedByString:@"~"].firstObject;
        }
        self.messenger.consultantName = self.consultantNameLabel.text;
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
                
            self.consultantNameLabel.text = @"";
            self.consultant = @"";
            self.messenger.consultantName = self.consultantNameLabel.text;
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
                [self.helperMessages addObject:[JSQMessage messageWithSenderId:senderId
                                                                   displayName:msg.userName
                                                                          text:msg.message]];
                self.itHelperButton.hidden = NO;
                if (!self.itHelperPopover.isPopoverVisible) _newHelpMessageCount++;
            } else {
                [self.chatMessages addObject:[JSQMessage messageWithSenderId:senderId
                                                                       displayName:msg.userName
                                                                              text:msg.message]];
                if (msg.priority == SessionChatMessagePriority_High) [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Message Sent", nil) maskType:SVProgressHUDMaskTypeBlack];
            }
        }
        [self.messenger finishReceivingMessage];
        [self.itHelper finishReceivingMessage];
        
        [self updateNoticeBadge:self.itHelperButton withCount:_newHelpMessageCount];
    });
}

- (void)onConsultantLost:(NSString *)consultant {
    DDLogDebug(@"onConsultantLost");
    // Never seen it happen
}


- (void)onSendWaitMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.chatMessages addObject:[JSQMessage messageWithSenderId:@""
                                                         displayName:@""
                                                                text:@"Dear customers: Please do not leave the classroom. Consultants are about to enter the classroom. Thank you for your patience."]];
        [self.messenger finishSendingMessage];
    });
    
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
        [self.messenger.inputToolbar.contentView.rightBarButtonItem
         setTitleColor:disable? UIColor.lightGrayColor: UIColorFromRGB(0x00C4EB)
         forState:UIControlStateDisabled];
    });
    
}

- (void)onHelpMessage:(NSNumber *)messageId status:(HelpMsgStatus)status {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (status) {
            case HelpMsgStatus_Done:
                self.helperResponses = [@[messageId] arrayByAddingObjectsFromArray:self.helperResponses];
                [self updateNoticeBadge:self.item4 withCount:self.helperResponses.count];
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
                [self.itHelper finishSendingMessage];
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
    [self showAlreadyLoginAlert];
}

- (void)onWhiteboardPageChanged:(int)pageIdx {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentPageLabel.text = [NSString stringWithFormat:@"%d", pageIdx + 1];
    });
    
}

- (void)onWhiteboardTotalPages:(int)totalPages {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.whiteboardPlaceholder.hidden = YES;
        self.totoalPageLabel.text = [NSString stringWithFormat:@"%d", totalPages];
    });
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
}

- (void)onPositionChanged:(long long)position {
    
    if (position == self.lastPosition && !self.videoPlaceholder.hidden) self.timeoutCounter++;
    
    if (self.timeoutCounter > kTimeoutInSeconds && self.consultant.length) {
        self.timeoutCounter = 0;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD showInfoWithStatus:@"A/V Loading..."];
//        });
    }
        
    self.lastPosition = position;
}

#pragma mark - Keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification {
    [self updateViewPosition: [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self updateViewPosition: [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]];
}

#pragma mark - Popover delegate
- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value {
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 0; // set value to 0 if you want to avoid the popover to be moved
}

- (void)didSelectPlainStyleItem:(NSIndexPath *)path sender:(id)sender withMessage:(NSString *)message {
    
    [self.popover dismissPopoverAnimated:YES];
    
    AlertView *alert = [[AlertView alloc] init];

    if (sender == self.item2) {
        
        // Talk to IT
        alert.contentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Send \"%@\" to IT?", nil), message];
        alert.rightButtonAction = ^(AlertView *alert) {
            [self.session sendHelpMessage:message msgIdx:@(path.row)];
            [alert dismissAll];
            
            // Block talk to IT button for 10 seconds
            [self performSelector:@selector(countDownForITHelperCallback) withObject:nil afterDelay:kCountDownTimerDuration];
            self.isITHelperEnabled = NO;
        };
        
    } else if (sender == self.item3) {
        
        // Talk to Consultant
        alert.contentLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Send \"%@\" to Consultant?", nil), message];
        alert.rightButtonAction = ^(AlertView *alert) {
            [self.session sendMessageToConsultatnt:message msgIndex:(int)path.row + 1];
            [alert dismissAll];
            
            // Block talk to Consultant button for 10 seconds
            [self performSelector:@selector(countDownForConsultantCallback) withObject:nil afterDelay:kCountDownTimerDuration];
            self.isConsultantHelperEnabled = NO;
        };
    }
    [alert show];
}

- (void)didSelectButtonStyleItem:(NSIndexPath *)path sender:(id)sender buttonIndex:(int)buttonIndex {
    
    [self.popover dismissPopoverAnimated:YES];
    switch (buttonIndex) {
        case 0:
            // Left button
            [self.session confirmHelpMsg:self.helperResponses[path.row] confirmed:HelpMsgConfirmed_Yes];
            
            break;
            
        case 1:
            // Middle button
            [self.session confirmHelpMsg:self.helperResponses[path.row] confirmed:HelpMsgConfirmed_Accept];
            break;
            
        case 2:
            // Right button
            [self.session confirmHelpMsg:self.helperResponses[path.row] confirmed:HelpMsgConfirmed_No];
            break;
            
        default:
            break;
    }
    NSMutableArray *newResponses = self.helperResponses.mutableCopy;
    [newResponses removeObjectAtIndex:path.row];
    self.helperResponses = newResponses;
    
    [self updateNoticeBadge:self.item4 withCount:self.helperResponses.count];
}

- (void)didUpdateMicrophoneVolume:(UISlider *)slider {
    if (slider.value) {
        [self openMicrophone];
    } else {
        [self closeMicrophone];
    }
}

#pragma mark - UI Actions
- (IBAction)manualRefreshPressed:(id)sender {
    [self onRelogin];
}

- (IBAction)stopButtonPressed:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    // D01Msg01
    AlertView *alert = [[AlertView alloc] init];
    alert.titleImage.image = [UIImage imageNamed:kINFO_ICON];
    alert.titleLabel.text = NSLocalizedString(@"Tip", nil);
    alert.contentLabel.text = NSLocalizedString(@"Sure to Exit?", nil);
    [alert.leftButton setTitle:NSLocalizedString(@"Stay", nil) forState:UIControlStateNormal];
    [alert.rightButton setTitle:NSLocalizedString(@"Exit", nil) forState:UIControlStateNormal];
    alert.rightButtonAction = ^(AlertView *alert) {
        self.session.delegate = nil;
        [self.session stopSession];
        [alert dismissAll];
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:UILiveSessionType1WillCloseNotification object:nil];
    };
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.view endEditing:YES];
    if ([segue.identifier isEqualToString:@"Popover"]) {
        
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
        UINavigationController *nav = segue.destinationViewController;
        PopoverMenuViewController *popoverMenu = (PopoverMenuViewController *)nav.topViewController;
        popoverMenu.delegate = self;
        popoverMenu.sender = sender;
        popoverMenu.session = self.session;
        popoverMenu.classInfo = self.classInfo;
        
        if (sender == self.item1) {
            
            popoverMenu.menuType = kPopoverMenuTypeSlider;
            popoverMenu.menuTitle = NSLocalizedString(@"Memeber Volume", nil);
            
            NSArray *arr;
            if (!self.isLobbySession) {
                arr = self.consultant.length?
                [@[NSLocalizedString(@"Mine", nil), _consultant] arrayByAddingObjectsFromArray:self.players.allObjects]:
                [@[NSLocalizedString(@"Mine", nil)] arrayByAddingObjectsFromArray:self.players.allObjects];
            } else {
                arr = self.consultant.length? @[_consultant]: @[];
            }
            
            popoverMenu.menu = arr;
            
            popoverMenu.preferredContentSize = CGSizeMake(kPopoverWidth, kPopoverCellHeightSlider * popoverMenu.menu.count + kPopoverTopMargin + kPopoverBottomMargin);
            
        } else if (sender == self.item2) {
            
            popoverMenu.menuTitle = NSLocalizedString(@"I'd like to talk to IT", nil);
            popoverMenu.menu = @[NSLocalizedString(@"There is communication noise", nil),
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
            popoverMenu.menuEnabled = self.isITHelperEnabled && !self.isDemo;
            popoverMenu.preferredContentSize = CGSizeMake(kPopoverWidth, kPopoverCellHeightPlain * popoverMenu.menu.count + kPopoverTopMargin + kPopoverBottomMargin);
            
        } else if (sender == self.item3) {
            popoverMenu.menuEnabled = YES;
            popoverMenu.menuTitle = NSLocalizedString(@"I'd like to talk to Consultant", nil);
            popoverMenu.menu = @[NSLocalizedString(@"Too fast", nil),
                                 NSLocalizedString(@"Too slow", nil),
                                 NSLocalizedString(@"Don't read context only", nil),
                                 NSLocalizedString(@"Correct me ASAP", nil),
                                 NSLocalizedString(@"Assist to answer", nil),
                                 NSLocalizedString(@"More time to talk", nil),
                                 NSLocalizedString(@"Classmates talk too much", nil),];
            popoverMenu.menuEnabled = self.isConsultantHelperEnabled && !self.isDemo;
            popoverMenu.preferredContentSize = CGSizeMake(kPopoverWidth, kPopoverCellHeightPlain * popoverMenu.menu.count + kPopoverTopMargin + kPopoverBottomMargin);
            
        } else if (sender == self.item4) {
            
            popoverMenu.menuType = kPopoverMenuTypeButton;
            popoverMenu.menuTitle = NSLocalizedString(@"Notification", nil);
            
            NSMutableArray *menu = [[NSMutableArray alloc] init];
            [self.helperResponses enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *helpItem = self.helpMsgMenu[obj.intValue];
                NSString *helpItemMsg = [NSString stringWithFormat: NSLocalizedString(@"%@ Problem is resolved", nil), helpItem];
                [menu addObject:helpItemMsg];
            }];
            popoverMenu.menu = menu;
            popoverMenu.preferredContentSize = CGSizeMake(kPopoverWidth, kPopoverCellHeightButton * (menu.count? menu.count: 1) + kPopoverTopMargin + kPopoverBottomMargin);
            
        }
        
        self.popover = [popoverSegue popoverControllerWithSender:sender
                                        permittedArrowDirections:WYPopoverArrowDirectionDown
                                                        animated:NO
                                                         options:WYPopoverAnimationOptionFade];
        self.popover.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"ITHelper"]) {
        [self itHelperButtonPressedForSegue:segue sender:sender];
    }
}

- (IBAction)itHelperButtonPressedForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
    UINavigationController *nav = segue.destinationViewController;

    UIImage *img1 = [UIImage imageNamed:@"sessionroom_btn_narrow"];
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img1.size.width, img1.size.height)];
    [button1 setBackgroundImage:img1 forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(minimizeHelperButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:button1];

    UIImage *img2 = [UIImage imageNamed:@"sessionroom_btn_close"];
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22.f, 22.f)];
    [button2 setBackgroundImage:img2 forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(closeHelperButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    self.itHelper = (ITHelperViewController *)nav.topViewController;
    self.itHelper.title = @"IT人員";
    self.itHelper.navigationItem.leftBarButtonItems = @[item2, item1];
    self.itHelper.session = self.session;
    self.itHelper.senderId = self.itHelper.senderDisplayName = self.session.shortUserName;
    self.itHelper.messages = self.helperMessages;
    self.itHelper.preferredContentSize = CGSizeMake(276.f, 380.f);
    self.itHelperPopover = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionDown animated:NO];
    self.itHelperPopover.delegate = self;
    
    // Reset new message count
    _newHelpMessageCount = 0;
    [self updateNoticeBadge:self.itHelperButton withCount:_newHelpMessageCount];
}

- (IBAction)closeHelperButtonPressed:(UIBarButtonItem *)sender {
    [self.itHelperPopover dismissPopoverAnimated:NO];
    self.itHelperButton.hidden = YES;
}

- (IBAction)minimizeHelperButtonPressed:(UIBarButtonItem *)sender {
    [self.itHelperPopover dismissPopoverAnimated:NO];
}

- (IBAction)micButtonPressed:(UIButton *)sender {
    if (_recorder.isRecording) {
        [self closeMicrophone];
    } else {
        [self openMicrophone];
    }
}

- (IBAction)pagePrevPressed:(id)sender {
    if (self.currentPageLabel.text.intValue > 1) {
        int prevPage = self.currentPageLabel.text.intValue - 1;
        [self.session switchWhiteboardPage:prevPage - 1];
    }
}

- (IBAction)pageNextPressed:(id)sender {
    if (self.currentPageLabel.text.intValue < self.totoalPageLabel.text.intValue) {
        int nextPage = self.currentPageLabel.text.intValue + 1;
        [self.session switchWhiteboardPage:nextPage - 1];
    }
}

- (IBAction)zoomInPressed:(id)sender {
    if (self.videoContainer.hidden) {
        
        self.videoContainerLeft.constant = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? kVideoContainerLeftNormal: kVideoContainerLeftNormalForiPhone;
        [self.zoomInButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_zoomin"] forState:UIControlStateNormal];
        
    } else {
        
        self.videoContainerLeft.constant = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? kVideoContainerLeftHidden: kVideoContainerLeftHiddenForiPhone;
        [self.zoomInButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_zoomout"] forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         self.videoContainer.hidden = !self.videoContainer.hidden;
                         self.chatView.superview.hidden = !self.chatView.superview.hidden;
                     }];
}

- (void)showReloadAlert {
    __weak LiveSessionType1ViewController *weakSelf = self;
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
        AlertView *alert = [AlertView showInfoWithTitle:NSLocalizedString(@"Tip", nil)
                                                   text:NSLocalizedString(@"Already login from other device", nil)];
        
        [alert.rightButton setTitle:NSLocalizedString(@"Exit", nil) forState:UIControlStateNormal];
        alert.rightButtonAction = ^(AlertView *alert) {
            self.session.delegate = nil;
            [self.session stopSession];
            [alert dismissAll];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:UILiveSessionType1WillCloseNotification object:nil];
        };
        alert.rightButtonWidthConstraint.constant = alert.bounds.size.width;
        alert.leftButtonWidthConstraint.constant = 0.f;
        alert.rightButtonWidthConstraint.constant = 255.f;
    });
}

- (IBAction)showTutorial:(UIBarButtonItem *)sender {
    UIViewController *introViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
    self.tutorialView = introViewController.view;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialPressed:)];
    [self.tutorialView addGestureRecognizer:self.tapGesture];
    [UIApplication.sharedApplication.keyWindow addSubview:self.tutorialView];
}

- (IBAction)tutorialPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsTutorialShowed];
    [self.tutorialView removeGestureRecognizer:self.tapGesture];
    [self.tutorialView removeFromSuperview];
}

#pragma mark - UI View functions
- (void)addShadow:(CALayer *)layer {
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 1.f;
    layer.shadowOpacity = .2f;
}

- (UIImage *)drawImage:(UIImage *)profileImage withBadge:(UIImage *)badge withText:(NSString *)count {
    UIGraphicsBeginImageContextWithOptions(profileImage.size, NO, 0.0f);
    [profileImage drawInRect:CGRectMake(0, 0, profileImage.size.width, profileImage.size.height)];
    [badge drawInRect:CGRectMake(profileImage.size.width - badge.size.width, 0, badge.size.width, badge.size.height)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, badge.size.width, badge.size.height)];
    label.text = count;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:11.f];
    label.textColor = [UIColor whiteColor];
    [label drawTextInRect:CGRectMake(profileImage.size.width - badge.size.width, 0, badge.size.width, badge.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [resultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)updateNoticeBadge:(id)item withCount:(NSUInteger)count {
    
    if ([item isMemberOfClass:UIBarButtonItem.class]) {
        
        UIImage *background = [UIImage imageNamed:@"sessionroom_nav_btn_notice_default"];
        UIImage *badge = [UIImage imageNamed:@"sessionroom_bg_notice"];
        
        UIBarButtonItem *barButton = (UIBarButtonItem *)item;
        barButton.image = count? [self drawImage:background withBadge:badge withText:[NSString stringWithFormat:@"%ld", count]]: background;
        
    } else if ([item isMemberOfClass:UIButton.class]) {
        
        UIImage *background = [UIImage imageNamed:@"sessionroom_icon_talktoit"];
        UIImage *badge = [UIImage imageNamed:@"sessionroom_bg_notice"];
        
        UIButton *button = (UIButton *)item;
        UIImage *image = count? [self drawImage:background withBadge:badge withText:[NSString stringWithFormat:@"%ld", count]]: background;
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
}

- (void)translateView:(UIView*)view toRect:(CGRect)rect withDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        // stub
    }];
}

- (void)updateViewPosition:(CGRect)frame {
    
    if (!CGRectIsNull(frame)) {
        CGRect localKeyboardFrame = frame;
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y = self.navigationController.navigationBar.frame.size.height + UIApplication.sharedApplication.statusBarFrame.size.height;
        
        if (CGRectGetMaxY(viewFrame) > CGRectGetMinY(localKeyboardFrame)) {

            viewFrame.origin.y = viewFrame.origin.y - CGRectGetHeight(localKeyboardFrame);
        }
        
        [self translateView:self.view toRect:viewFrame withDuration:kTranslateDuration];
    } else {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y = 0;
        [self translateView:self.view toRect:viewFrame withDuration:kTranslateDuration];
    }
}

- (IBAction)collapseVideoPressed:(id)sender {
    
    if (self.videoPlaceholder.hidden) {

        self.videoContainerTop.constant = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? kVideoContainerTopNormal: kVideoContainerTopNormalForiPhone;
        [self.collapseButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_camera_default"] forState:UIControlStateNormal];
        [self.collapseButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_camera_highlight"] forState:UIControlStateHighlighted];
        
    } else {
        
        self.videoContainerTop.constant = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? kVideoContainerTopHidden: kVideoContainerTopHiddenForiPhone;
        [self.collapseButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_camera_disable"] forState:UIControlStateNormal];
        [self.collapseButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_camera_disable_highlight"] forState:UIControlStateHighlighted];
    }

    float bottomEdge = self.messenger.collectionView.contentOffset.y + self.messenger.collectionView.frame.size.height;
    BOOL isBottom = bottomEdge >= self.messenger.collectionView.contentSize.height;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.view layoutIfNeeded];
                         if (isBottom) [self.messenger scrollToBottomAnimated:YES];
                         
                     } completion:^(BOOL finished) {
                         
                         self.videoView.hidden = self.videoPlaceholder.hidden = !self.videoPlaceholder.hidden;
                         
                     }];
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
                [self.micButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_mike_default"] forState:UIControlStateNormal];
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
            [self.micButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_mike_disable"] forState:UIControlStateNormal];
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
    
    self.micVolume.image = [UIImage imageNamed:imageName];
}

- (BOOL)isLobbySession {
    NSLog(@"%@", self.classInfo[@"lobbySession"]);
    return [@"true" isEqualToString:self.classInfo[@"lobbySession"]] || [@"Y" isEqualToString:self.classInfo[@"lobbySession"]];
}

- (void)initSession {
    // Reset chat view
    [self.helperMessages removeAllObjects];
    [self.itHelper finishReceivingMessage];
    [self.chatMessages removeAllObjects];
    [self.messenger finishReceivingMessage];
    
    // Stop session
    [self.session stopSession];

    // Reset Session info
    if (!self.session) {
        self.session = [[LiveSession alloc] initSessionWithClassInfo:self.classInfo delegate:self streamerView:nil consultantView:self.videoView whiteboardView:self.materialView];
        self.session.defaultUserVolumeFactor = kDefaultUserVolumeFactor;
    }
    
    self.session.delegate = self;
    
    self.consultantNameLabel.text = @"";
    self.consultant = @"";
    self.currentPageLabel.text = @"1";
    self.totoalPageLabel.text = @"1";
    self.lastPosition = -1;
    self.timeoutCounter = 0;
    self.isITHelperEnabled = YES;
    self.isConsultantHelperEnabled = YES;
    
    // Reset Messenger
    self.messenger.session = self.session;
    self.messenger.senderId = self.session.shortUserName;
    self.messenger.senderDisplayName = self.session.shortUserName;
    self.messenger.messages = self.chatMessages;
    self.messenger.consultantName = self.consultantNameLabel.text;
}

- (void)countDownForITHelperCallback {
    self.isITHelperEnabled = YES;
}

- (void)countDownForConsultantCallback {
    self.isConsultantHelperEnabled = YES;
}

#pragma mark - KVO
- (void)_addKeyValueObserver {
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
            if (self.videoDisabledByTutorConsole == 0 && !self.videoPlaceholder.hidden)
                self.videoView.hidden = NO;
            else
                self.videoView.hidden = YES;
        });
    }
}

@end
