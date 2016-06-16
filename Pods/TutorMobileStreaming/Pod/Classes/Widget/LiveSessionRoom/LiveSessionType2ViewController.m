//
//  LiveSessionType2ViewController
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/10/27.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "LiveSessionType2ViewController.h"

#import "ChatButton.h"
#import "TutorLog.h"
#import "DeviceUtility.h"
#import "LiveSession.h"
#import "CircleProgressView.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <AlertView/AlertView.h>
#import <SVProgressHUD/SVProgressHUD.h>

#define kTranslateDuration 0.5                  // Translation duration of view
static int const kFPSZeroTimeout = 10;           // Reload session if FPS is 0
static NSString * const kIsTutorialShowed = @"LiveSessionType2ViewController.isTutorialShowed";
NSString *const _Nonnull UILiveSessionType2WillCloseNotification = @"UILiveSessionType2WillCloseNotification";

@interface LiveSessionType2ViewController () <LiveSessionDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet CircleProgressView *countdownView;
@property (nonatomic, weak) IBOutlet UIView *videoPlaceholder;
@property (nonatomic, weak) IBOutlet UIView *videoView;
@property (nonatomic, weak) IBOutlet UIView *whiteboardView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *materialView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *whiteboardPlaceholder;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *switchLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *switchButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *exitLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *tutorialView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *micStatusLabel;

@property (nonatomic, strong) LiveSession *session;

@property (nonatomic, strong) NSString *cohost;
@property (nonatomic, strong) NSString *coordinator;
@property (nonatomic, strong) NSSet *players;
@property (nonatomic, strong) NSArray *helperResponses;

@property (nonatomic, assign) int lastFps;
@property (nonatomic, assign) NSUInteger fpsZeroCounter;

@property (nonatomic, strong) NSTimer *sessionTimer;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@end

@implementation LiveSessionType2ViewController

- (instancetype)init {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LiveSessionType2_iPad" bundle:nil];
    
    self = (LiveSessionType2ViewController *)[sb instantiateViewControllerWithIdentifier:@"LiveSessionType2ViewController"];
    
    if (self) {
        // your statement
        
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lastFps = -1;
    self.fpsZeroCounter = 0;
    self.videoView.contentMode = UIViewContentModeScaleAspectFill;
    [self.countdownView setProgress:@0];
    
    // Init session
    self.session = [[LiveSession alloc] initSessionWithClassInfo:self.classInfo delegate:self streamerView:nil consultantView:self.videoView whiteboardView:self.materialView];
    
    self.sessionTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sessionTimerCallback:) userInfo:nil repeats:YES];
    
    _switchLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _exitLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.micStatusLabel.layer.borderColor = UIColor.whiteColor.CGColor;
    self.micStatusLabel.layer.shadowColor = UIColor.blackColor.CGColor;
    self.micStatusLabel.hidden = ![self.session getMicrophoneMute];
    
    // Check if user needs tutorial
    BOOL isTutorialShowed = [[NSUserDefaults standardUserDefaults] boolForKey:kIsTutorialShowed];
    
    if (!isTutorialShowed) {
        NSLog(@"Tutorial is not showed before");
        self.tutorialView.hidden = NO;
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialPressed:)];
        [self.tutorialView addGestureRecognizer:self.tapGesture];
    } else {
        self.tutorialView.hidden = YES;
    }
}

- (void)sessionTimerCallback:(NSTimer *)timer {
    // 15 mins = 15 * 60 sec = 1
    // 0.5 sec = 0.5*1/900
    NSNumber *increment = @(0.5*1/900);
//    NSLog(@"timer: %f, %@", self.countdownView.currentValue, @(self.countdownView.currentValue + increment.floatValue));
    [self.countdownView setProgress:@(self.countdownView.currentValue + increment.floatValue)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.whiteboardView.hidden = (currentOrientation == UIInterfaceOrientationPortrait ||
                                  currentOrientation == UIInterfaceOrientationPortraitUpsideDown);
    self.switchLabel.text = self.whiteboardView.hidden? @"切換教材": @"顧問視訊";
    [self.switchButton setBackgroundImage:[UIImage imageNamed:self.whiteboardView.hidden? @"Doc Icon": @"Video Icon"] forState:UIControlStateNormal];
    
    // Start session
    [self.session startSession];
    
    // Disable screen lock
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop session
    self.session.delegate = nil;
    [self.session stopSession];
    [_sessionTimer invalidate];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}



#pragma mark - Session Delegate
- (void)onAnchorChanged:(NSString *)anchor {
    DDLogDebug(@"onAnchorChanged: %@", anchor);
    
}

- (void)onUserIn:(NSString *)userName role:(NSString *)role {
    DDLogDebug(@"onUserIn - userName:%@, role:%@", userName, role);
}

- (void)onUserOut:(NSString *)userName {
    DDLogDebug(@"onUserOut - userName:%@", userName);
}



- (void)onMessage:(NSArray *)messages {
    
}

- (void)onConsultantLost:(NSString *)consultant {
    DDLogDebug(@"onConsultantLost");
    // Never seen it happen
}


- (void)onSendWaitMsg {
    //
}

- (void)onMicMute:(BOOL)mute {
    DDLogDebug(@"onMicMute: %@", @(mute));
    float gain = [self.session getMicrophoneGain];
    [self.session setMicrophoneGain:mute? 0.f: gain];
    [self.session setMicrophoneMute:mute];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.micStatusLabel.hidden = !mute;
    });
}

// request from server, upper layer needs to decide if need to disable video or not
- (void)onDisableVideo:(int)disable {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoView.hidden = disable;
    });
}

// request from server, upper layer needs to decide if need to disable chat or not
- (void)onDisableChat:(int)disable {
    //
}

- (void)onHelpMessage:(NSNumber *)msgIdx status:(HelpMsgStatus)status {
    
}

// request from server, upper layer needs to decide if need to relogin or not
- (void)onRelogin {
    [self performSelectorOnMainThread:@selector(restartSession) withObject:nil waitUntilDone:NO];
}

// request from server, upper layer needs to decide if need to show admin message or not
- (void)onAdminMessage:(NSString *)msg {
    
    AlertView *alert = [[AlertView alloc] init];
    alert.titleLabel.text = msg;
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
    
}

- (void)onWhiteboardPageChanged:(int)pageIdx {
    
}

- (void)onWhiteboardTotalPages:(int)totalPages {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.whiteboardPlaceholder.hidden = YES;
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
    
    if (fps == 0 && self.lastFps == 0) self.fpsZeroCounter++;
    
    if (self.fpsZeroCounter > kFPSZeroTimeout) {

        self.fpsZeroCounter = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:@"Connection timeout"];
            self.session.delegate = nil;
            [self.session stopSession];
            
            self.session = nil;
            [self.whiteboardView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self performSelector:@selector(restartSession) withObject:nil afterDelay:1];
            
        });
    }
    self.lastFps = fps;
}

- (void)onPositionChanged:(long long)position {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
    });   
}

#pragma mark - UI Actions
- (IBAction)switchPressed:(id)sender {
    self.whiteboardView.hidden = !self.whiteboardView.hidden;
    self.switchLabel.text = self.whiteboardView.hidden? @"切換教材": @"顧問視訊";
    [self.switchButton setBackgroundImage:[UIImage imageNamed:self.whiteboardView.hidden? @"Doc Icon": @"Video Icon"] forState:UIControlStateNormal];
}

- (IBAction)closePressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确定要离开课程吗?" delegate:self cancelButtonTitle:@"再上一下" otherButtonTitles:@"心意已决", nil];
    [alert show];
}

- (IBAction)tutorialPressed:(id)sender {
    self.tutorialView.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsTutorialShowed];
    [self.tutorialView removeGestureRecognizer:self.tapGesture];
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) [self dismissViewControllerAnimated:YES completion:^{
        if (self.closeButtonAction) {
            self.closeButtonAction();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UILiveSessionType2WillCloseNotification object:nil];
    }];
}

#pragma mark - Roatation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"toInterfaceOrientation: %ld", toInterfaceOrientation);
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
        toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        self.whiteboardView.hidden = YES;
        
    } else {
        self.whiteboardView.hidden = NO;
    }
    self.switchLabel.text = self.whiteboardView.hidden? @"切換教材": @"顧問視訊";
    [self.switchButton setBackgroundImage:[UIImage imageNamed:self.whiteboardView.hidden? @"Doc Icon": @"Video Icon"] forState:UIControlStateNormal];
}

#pragma mark - UI View functions
- (BOOL)isLobbySession {
    NSLog(@"%@", self.classInfo[@"lobbySession"]);
    return [@"true" isEqualToString:self.classInfo[@"lobbySession"]] || [@"Y" isEqualToString:self.classInfo[@"lobbySession"]];
}

- (void)restartSession {
    [SVProgressHUD showInfoWithStatus:@"Reloading..."];
    self.session = [[LiveSession alloc] initSessionWithClassInfo:self.classInfo delegate:self streamerView:nil consultantView:self.videoView whiteboardView:self.whiteboardView];
    
    [self.session startSession];
    self.videoView.hidden = NO;
    
}
@end
