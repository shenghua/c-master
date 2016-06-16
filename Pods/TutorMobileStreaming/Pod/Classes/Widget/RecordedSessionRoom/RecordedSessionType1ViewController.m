//
//  RecordedSessionType1ViewController.m
//  Pods
//
//  Created by TingYao Hsu on 2015/11/3.
//
//

#import "RecordedSessionType1ViewController.h"

#import "RecordedSession.h"
#import "MessagesViewController.h"
#import "UILabel+CustomFont.h"

#import <JSQMessagesViewController/JSQMessage.h>
#import <AlertView/AlertView.h>


NSString *const _Nonnull UIRecordSessionType1WillCloseNotification = @"UIRecordSessionType1WillCloseNotification";
static int const kVideoContainerTopNormal = 20;
static int const kVideoContainerTopHidden = 20 - 245;

@interface RecordedSessionType1ViewController () <RecordedSessionDelegate, UIAlertViewDelegate>
@property (nonatomic, assign) NSTimeInterval countDownDuration;
@property (nonatomic, copy) void (^playbackCallback) (RecordedSessionType1ViewController *viewController);
@property (nonatomic, strong) RecordedSession *session;
@property (nonatomic, strong) MessagesViewController *messenger;
@property (nonatomic, strong) NSMutableArray *chatMessages;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *videoView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *materialView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *consultantNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *whiteboardPlaceholder;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *totalPageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *seekbarSlider;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *currentPositionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *durationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *pauseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *videoContainerTop;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *collapseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *videoPlaceholder;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *bottomView;

@property (assign, nonatomic) long long duration;
@property (assign, nonatomic) long long lastTimecode;
@property (assign, nonatomic) float lastPosition;
@property (assign, nonatomic) float lastSeekPosition;
@property (assign, nonatomic) BOOL isSeeking;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL sessionDidStopped;
@property (strong, nonatomic) AlertView *alert;

@property (nonatomic, strong) NSTimer *hideBottomViewTimer;
@end

@implementation RecordedSessionType1ViewController
- (instancetype)init {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RecordedSessionRoom_iPad" bundle:nil];
    
    self = (RecordedSessionType1ViewController *)[sb instantiateViewControllerWithIdentifier:@"RecordedSessionType1ViewController"];
    
    if (self) {
        // your statement
        
    }
    return self;
}

- (instancetype)initWithServer:(NSString *)server
                     sessionSn:(NSString *)sessionSn
                 classStartMin:(NSString *)classStartMin {
    self = [self init];
    if (self) {
        // Init session
        
        self.server = server;
        self.sessionSn = sessionSn;
        self.classStartMin = classStartMin? classStartMin: @"30";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    [currentDevice setValue:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
    
    self.navigationController.navigationBarHidden = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 10, 30, 30);
    [backButton setImage:[UIImage imageNamed:@"VABack"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"VABack"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sessionroom_logo"]];
    self.navigationItem.leftBarButtonItem.image = [[UIImage imageNamed:@"sessionroom_btn_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [[UILabel appearanceWhenContainedIn:self.class, nil] setSubstituteFontName:@"Montserrat-Regular"];
    
    [self.seekbarSlider setMinimumTrackImage:[UIImage imageNamed:@"sessionroom_bg_slider"] forState:UIControlStateNormal];
    
    NSAssert([self.childViewControllers.lastObject isKindOfClass:MessagesViewController.class], @"Session Room should have MessagesViewController");
    self.messenger = (MessagesViewController *)self.childViewControllers.lastObject;
    self.chatMessages = [NSMutableArray new];
    
    [self initSession];
    [self.session startSession:0];
    
    [self performSelector:@selector(callbackMethod) withObject:nil afterDelay:self.countDownDuration];
    
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBottomView)];
//    self.view.userInteractionEnabled = YES;
//    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Observe screen lock
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnteredBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
//    [self performSelector:@selector(hideBottomView) withObject:nil afterDelay:2];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.session.delegate = nil;
    [self.session stopSession];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // Remove Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleEnteredForeground:(id)sender {
    [self initSession];
    [self.session startSession:0];
}

- (void)handleEnteredBackground:(id)sender {
    self.session.delegate = nil;
    [self.session stopSession];
    
}

- (IBAction)buttonPressed:(id)sender {
    [self stopButtonPressed:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPlaybackCallback:(void (^)(RecordedSessionType1ViewController *viewController))callback withInterval:(NSTimeInterval)time {
    self.countDownDuration = time;
    self.playbackCallback = callback;
}


- (void)callbackMethod {
    if (self.playbackCallback) {
        self.playbackCallback(self);
    }
}

- (void)showBottomView
{
    self.bottomView.hidden = NO;
    
//    [self performSelector:@selector(hideBottomView) withObject:nil afterDelay:3];
    
//    [self.hideBottomViewTimer invalidate];
//    
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
//    self.hideBottomViewTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideBottomViewTimer) userInfo:nil repeats:NO];//[[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:3] interval:0 target:self selector:@selector(hideBottomViewTimer) userInfo:nil repeats:NO];
//    [[NSRunLoop currentRunLoop] addTimer:self.hideBottomViewTimer forMode:NSRunLoopCommonModes];

}

- (void)hideBottomView
{
    self.bottomView.hidden = YES;
}

- (IBAction)pausePressed:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"暂停"]) {
        [self.session pause];
        [self.pauseButton setTitle:@"播放" forState:UIControlStateNormal];
    } else {
        [self.session resume];
        [self.pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
    
}
#pragma mark - private methods
- (void)initSession {
    
    // Reset video view
    [self.videoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Reset whiteboard view
    [self.materialView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Reset chat view
    [self.chatMessages removeAllObjects];
    [self.messenger finishReceivingMessage];
    
    self.messenger.inputToolbar.hidden = YES;
    
    // Stop session
    [self.session stopSession];
    self.session = nil;
    
    NSDictionary *sessionInfo = @{@"sessionSn": self.sessionSn, @"server": self.server, @"classStartMin": self.classStartMin};
    self.session = [[RecordedSession alloc] initSession:sessionInfo delegate:self videoView:self.videoView whiteboardView:self.materialView];
    
    self.messenger.senderId = self.session.shortUserName? self.session.shortUserName: @"Guest";
    self.messenger.senderDisplayName = self.session.shortUserName? self.session.shortUserName: @"Guest";
    self.messenger.messages = self.chatMessages;
    
    self.consultantNameLabel.text = @"";
    
    self.currentPageLabel.text = @"1";
    self.totalPageLabel.text = @"1";
    self.lastPosition = 0;
    self.lastSeekPosition = 0;
    self.seekbarSlider.enabled = NO;
    self.duration = -1;
    self.isSeeking = NO;
    self.isLoading = NO;
    
    [self.loadingView startAnimating];
    self.seekbarSlider.enabled = self.pauseButton.enabled = NO;
}

- (IBAction)seekbarChanged:(UISlider *)sender {
    NSLog(@"slider value = %f", sender.value);
    
    float pos = (self.duration * sender.value / 1000);
    self.currentPositionLabel.text = [self formatTimeInterval:pos];
}

- (IBAction)seekbarTouchUp:(UISlider *)sender {
    self.isSeeking = NO;
    self.isLoading = YES;
    [self.loadingView startAnimating];
    if (self.sessionDidStopped) {
        [self.session startSession:self.duration * sender.value];
        self.sessionDidStopped = NO;
    } else {

        [self.session seek:self.duration * sender.value];
    }
    self.lastSeekPosition = sender.value;
}

- (IBAction)seekbarTouchDown:(UISlider *)sender {
    self.isSeeking = YES;
}

- (IBAction)collapseVideoPressed:(id)sender {
    
    if (self.videoContainerTop.constant == kVideoContainerTopHidden) {
        
        self.videoContainerTop.constant = kVideoContainerTopNormal;
        [self.collapseButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_camera_default"] forState:UIControlStateNormal];
        
    } else {
        
        self.videoContainerTop.constant = kVideoContainerTopHidden;
        [self.collapseButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_camera_disable"] forState:UIControlStateNormal];
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

#pragma mark - private method
- (NSString *)formatTimeInterval:(int)seconds {
    seconds = MAX(0, seconds);
    
    int s = seconds;
    int m = s / 60;
    int h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    return [NSString stringWithFormat:@"%0.2d:%0.2d:%0.2d", h, m ,s];
}

- (void)showReloadAlert {
    
    __weak RecordedSessionType1ViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.alert) return;
        NSLog(@"showReloadAlert");
        self.alert = [AlertView showInfoWithTitle:NSLocalizedString(@"Tip", nil)
                                             text:NSLocalizedString(@"Internet Unavilable", nil)];
        
        [self.alert.rightButton setTitle:@"重新載入" forState:UIControlStateNormal];
        self.alert.rightButtonAction = ^(AlertView *alert) {
            [weakSelf initSession];
            [weakSelf.session startSession:0];
            [alert dismissAll];
            weakSelf.alert = nil;
        };
    });
}

- (IBAction)stopButtonPressed:(UIBarButtonItem *)sender {
    
    UIAlertView *exitAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"确认退出" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    [exitAlertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIDevice *currentDevice = [UIDevice currentDevice];
        [currentDevice setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
        
        self.session.delegate = nil;
        [self.session stopSession];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIRecordSessionType1WillCloseNotification object:nil];
    }
}

#pragma mark - Recorded Session delegate
- (void)onSessionStarted:(BOOL)success {
    NSLog(@"onSessionStarted: %d", success);
    if (!success) {
        [self showReloadAlert];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onSessionStarted:)]) {
        [_delegate onSessionStarted:success];
    }
}

- (void)onSessionStopped {
    NSLog(@"onSessionStopped");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.seekbarSlider.value = 1.f;
        self.currentPositionLabel.text = [self formatTimeInterval:(int)self.duration/1000];
//        self.seekbarSlider.enabled = self.pauseButton.enabled = NO;
        self.seekbarSlider.enabled = YES;
        self.sessionDidStopped = YES;
    });
//    [self showReloadAlert];
    
    if (_delegate && [_delegate respondsToSelector:@selector(onSessionStopped)]) {
        [_delegate onSessionStopped];
    }
}

- (void)onSessionDuration:(long long)duration { // milliseconds
    NSLog(@"onSessionDuration");
    self.duration = duration;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.durationLabel.text = [self formatTimeInterval:(int)duration/1000];
        
        if (self.lastTimecode) {
            [self.session seek:self.lastTimecode];
            self.lastSeekPosition = 1.f * self.lastTimecode / duration;
            self.isLoading = YES;
            NSLog(@"seek to: %lld", self.lastTimecode);
        }
    });
    
    if (_delegate && [_delegate respondsToSelector:@selector(onSessionDuration:)]) {
        [_delegate onSessionDuration:duration];
    }
}

- (void)onPositionChanged:(long long)position { // milliseconds
    NSLog(@"onPositionChanged");
    self.lastTimecode = position;
    
    float pos = 1.f * position / self.duration;
    
    NSLog(@"pos: %f, lstseek: %.3f, lastpos: %.3f, loading: %d",
          pos,
          self.lastSeekPosition,
          self.lastPosition,
          self.isLoading);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.seekbarSlider.enabled = self.pauseButton.enabled = position > 0 && self.duration > position;
    });
    
    // Update seekbar only if no seeking and no loading
    if (!self.isSeeking && !self.isLoading) {
        self.lastPosition = pos;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.seekbarSlider.value = MIN(pos, 1);
            self.currentPositionLabel.text = [self formatTimeInterval:(int)MIN(position, self.duration)/1000];
        });
    }
    
    if (self.isLoading) {
        
        BOOL isForward = self.lastPosition < self.lastSeekPosition;
        BOOL isForwardWaiting = pos <= self.lastSeekPosition;
        BOOL isBackward = self.lastPosition > self.lastSeekPosition;
        BOOL isBackwardWaiting = pos <= self.lastSeekPosition || pos >= self.lastPosition;
//        BOOL isFinished = pos - self.lastSeekPosition < 0.005 && pos - self.lastSeekPosition > 0;
        
        if (isBackward) {
            NSLog(@"isBackward: %d, isBackwardWaiting: %d, diff: %f, pos: %f",
                  isBackward,
                  isBackwardWaiting,
                  pos - self.lastSeekPosition,
                  pos);
        } else {
            NSLog(@"isForward: %d, isForwardWaiting: %d, diff: %f, pos: %f",
                  isForward,
                  isForwardWaiting,
                  pos - self.lastSeekPosition,
                  pos);
        }
        self.isLoading = ((isForwardWaiting && isForward) || (isBackwardWaiting && isBackward));
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopAnimating];
        });
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onPositionChanged:)]) {
        [_delegate onPositionChanged:position];
    }
}

- (void)onUserIn:(NSString *)userName isPresenter:(BOOL)isPresenter {
    NSLog(@"onUserIn: %@, %d", userName, isPresenter);
    if (isPresenter) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.consultantNameLabel.text = [userName componentsSeparatedByString:@"~"].firstObject;
        });
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onUserIn:isPresenter:)]) {
        [_delegate onUserIn:userName isPresenter:isPresenter];
    }
}

- (void)onMessage:(NSArray<SessionChatMessage *> *)messages {
    NSLog(@"onMessage");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (SessionChatMessage *msg in messages) {
            NSLog(@"onMessage - userName:%@, Time:%@, message:%@, important:%d", msg.userName, msg.time, msg.message, msg.priority);
            
            BOOL isITMessage = [msg.userName rangeOfString:@" to "].location != NSNotFound;
            BOOL hasCurrentUserName = self.session.shortUserName && [msg.userName rangeOfString:self.session.shortUserName].location != NSNotFound;
            if (isITMessage && !hasCurrentUserName) continue; // Skip IT message to other users
            
            NSString *senderId =
                msg.priority == SessionChatMessagePriority_High &&
                self.session.shortUserName?
                    self.session.shortUserName:msg.userName;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm:ss";
            NSDate *date = [dateFormatter dateFromString:msg.time];
            
            JSQMessage *jsqMsg = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:msg.userName date:date text:msg.message];
            [self.messenger.messages addObject:jsqMsg];
        }
        [self.messenger finishReceivingMessage];
        float bottomEdge = self.messenger.collectionView.contentOffset.y + self.messenger.collectionView.frame.size.height;
        BOOL isBottom = bottomEdge >= self.messenger.collectionView.contentSize.height;
        if (isBottom) {
            [self.messenger scrollToBottomAnimated:YES];
        }
        
    });
    
    if (_delegate && [_delegate respondsToSelector:@selector(onMessage:)]) {
        [_delegate onMessage:messages];
    }
}

- (void)onClearAllMessages { // called after seeking
    NSLog(@"onClearAllMessages");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messenger.messages removeAllObjects];
        [self.messenger finishReceivingMessage];
    });
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClearAllMessages)]) {
        [_delegate onClearAllMessages];
    }
}

- (void)onWhiteboardPageChanged:(int)pageIdx {   // starting from 0
    NSLog(@"onWhiteboardPageChanged");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentPageLabel.text = [NSString stringWithFormat:@"%d", pageIdx + 1];
    });
    
    if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardPageChanged:)]) {
        [_delegate onWhiteboardPageChanged:pageIdx];
    }
}

- (void)onWhiteboardTotalPages:(int)totalPages {
    NSLog(@"onWhiteboardTotalPages");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.whiteboardPlaceholder.hidden = YES;
        self.totalPageLabel.text = [NSString stringWithFormat:@"%d", totalPages];
    });
    
    if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardTotalPages:)]) {
        [_delegate onWhiteboardTotalPages:totalPages];
    }
}

- (void)onVideoFps:(int)fps {
//    NSLog(@"onVideoFps");
    if (_delegate && [_delegate respondsToSelector:@selector(onVideoFps:)]) {
        [_delegate onVideoFps:fps];
    }

}

#pragma mark - Autorotate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}
@end
