//
//  RecordedSessionRoomViewController.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/15.
//
//

#import "RecordedSessionRoomViewController.h"
#import "TutorLog.h"
#import "DeviceUtility.h"

#define kVideoViewScale 2
#define kAnimationDuration 0.2

#define kProgressLabelW     30.0
#define kProgressSliderH    20.0
#define kProgressSliderBottom    80.0
#define kPlayBtnH   40.0
#define kPlayBtnW   40.0
#define kExitBtnH   40.0
#define kExitBtnW   40.0

@interface RecordedSessionRoomViewController ()
@property (nonatomic, strong) RecordedSession *session;
@property (nonatomic, assign) long long sessionDuration;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) ChatView *chatView;
@property (nonatomic, strong) UIView *whiteboardView;
@property (nonatomic, assign) BOOL sessionInProcess;

@property (nonatomic, strong) UILabel *currentPosLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *exitButton;
@end

@implementation RecordedSessionRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sessionInProcess = NO;
    
    // Init session
    _session = [[RecordedSession alloc] initSession:_sessionInfo delegate:self videoView:_videoView whiteboardView:_whiteboardView];
    
    // Set up gesture for video view
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_moveViewWithGestureRecognizer:)];
    [_videoView addGestureRecognizer:panGestureRecognizer];
    
    // Hide navigation bar
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)viewDidDisappear:(BOOL)animated {

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    // Start session
    [_session startSession:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Show status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // Stop session
    [_session stopSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Layout
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loadView {
    CGRect bounds = CGRectMake(0, 0, [DeviceUtility screenSize].width, [DeviceUtility screenSize].height);
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor blackColor];
    
    //    DDLogDebug(@"self.view.frame = x (%f), y (%f), w (%f), h (%f)", self.view.frame.origin.x,
    //               self.view.frame.origin.y,
    //               self.view.frame.size.width,
    //               self.view.frame.size.height);
    
    // Create whiteboard view
    CGRect whiteboardViewFrame = [self _getWhiteboardViewFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadWhiteboardView:whiteboardViewFrame];
    
    // Create chat view
    CGRect chatViewFrame = [self _getChatViewFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadChatView:chatViewFrame];
    
    // Create current position label
    CGRect currentPosLabelFrame = [self _getCurrentPosLabelFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadCurrentPosLabel:currentPosLabelFrame];
    
    // Create duration label
    CGRect durationLabelFrame = [self _getDurationLabelFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadDurationLabel:durationLabelFrame];
    
    // Create progress slider
    CGRect progressSliderFrame = [self _getProgressSliderFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadProgressSlider:progressSliderFrame];
    
    // Create play button
    CGRect playButtonFrame = [self _getPlayButtonFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadPlayButton:playButtonFrame];
    
    // Create exit button
    CGRect exitButtonFrame = [self _getExitButtonFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadExitButton:exitButtonFrame];
    
    // Create video view
    CGRect videoViewFrame = [self _getVideoViewFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadVideoView:videoViewFrame];
}

- (void)_loadVideoView:(CGRect)frame {
    _videoView = [[UIView alloc] initWithFrame:frame];
    [_videoView setContentMode:UIViewContentModeScaleAspectFill];
    _videoView.clipsToBounds = YES;
    _videoView.backgroundColor = [UIColor blackColor];
    _videoView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:_videoView];
}

- (void)_loadWhiteboardView:(CGRect)frame {
    _whiteboardView = [[UIView alloc] initWithFrame:frame];
    _whiteboardView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //    _whiteboardView.backgroundColor = [UIColor whiteColor];
    _whiteboardView.clipsToBounds = YES;
    
    [self.view addSubview:_whiteboardView];
}

- (void)_loadChatView:(CGRect)frame {
    _chatView = [[ChatView alloc] initWithFrame:frame];
    _chatView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    _chatView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:_chatView];
}

- (void)_loadCurrentPosLabel:(CGRect)frame {
    _currentPosLabel = [[UILabel alloc] initWithFrame:frame];
    _currentPosLabel.backgroundColor = [UIColor grayColor];
    _currentPosLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [_currentPosLabel setText:@"00:00"];
    _currentPosLabel.textColor = [UIColor whiteColor];
    _currentPosLabel.adjustsFontSizeToFitWidth = YES;
    _currentPosLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_currentPosLabel];
}

- (void)_loadDurationLabel:(CGRect)frame {
    _durationLabel = [[UILabel alloc] initWithFrame:frame];
    _durationLabel.backgroundColor = [UIColor grayColor];
    _durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [_durationLabel setText:@"00:00"];
    _durationLabel.textColor = [UIColor whiteColor];
    _durationLabel.adjustsFontSizeToFitWidth = YES;
    _durationLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_durationLabel];
}

- (void)_loadProgressSlider:(CGRect)frame {
    _progressSlider = [[UISlider alloc] initWithFrame:frame];
    _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _progressSlider.continuous = NO;
    _progressSlider.value = 0;
    [_progressSlider addTarget:self action:@selector(_progressDidChange:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_progressSlider];
}

- (void)_loadPlayButton:(CGRect)frame {
    _playButton = [[UIButton alloc] initWithFrame:frame];
    _playButton.backgroundColor = [UIColor greenColor];
    _playButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [_playButton setTitle:@"Pause" forState:UIControlStateNormal];
    _playButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_playButton addTarget:self action:@selector(_playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_playButton];
}

- (void)_loadExitButton:(CGRect)frame {
    _exitButton = [[UIButton alloc] initWithFrame:frame];
    _exitButton.backgroundColor = [UIColor redColor];
    _exitButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [_exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    _exitButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_exitButton addTarget:self action:@selector(_exitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_exitButton];
}

#pragma mark - UI Actions

- (void)_moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    // Translate view
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x + translation.x,
                                                   panGestureRecognizer.view.center.y + translation.y);
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:panGestureRecognizer.view];
    
    // Move view to corner after all fingers being lifted
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self _moveViewToCorner:panGestureRecognizer.view fromPosition:[panGestureRecognizer locationInView:self.view]];
    }
}

- (void)_progressDidChange:(UISlider *)sender {
    NSLog(@"slider value = %f", sender.value);
    
    _currentPosLabel.text = [self _formatTimeInterval:(int)(_sessionDuration * sender.value / 1000)];
    
    if (_sessionInProcess && _session)
        [_session seek:_sessionDuration * sender.value];
    else if (_session)
        [_session startSession:_sessionDuration * sender.value];
}

- (void)_playButtonClicked:(UIButton *)sender {
    if (_session && [_playButton.titleLabel.text isEqualToString:@"Play"]) {
        [_session resume];
        [_playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else if (_session && [_playButton.titleLabel.text isEqualToString:@"Pause"]) {
        [_session pause];
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (void)_exitButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Rotation Handler
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0) {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // The device has already rotated, that's why this method is being called.
    UIInterfaceOrientation toOrientation   = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    // Fix orientation mismatch (between UIDeviceOrientation and UIInterfaceOrientation)
    if (toOrientation == UIInterfaceOrientationLandscapeRight) toOrientation = UIInterfaceOrientationLandscapeLeft;
    else if (toOrientation == UIInterfaceOrientationLandscapeLeft) toOrientation = UIInterfaceOrientationLandscapeRight;
    
    UIInterfaceOrientation fromOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self willRotateToInterfaceOrientation:toOrientation duration:0.0];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self willAnimateRotationToInterfaceOrientation:toOrientation duration:[context transitionDuration]];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self didRotateFromInterfaceOrientation:fromOrientation];
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Update view frame
    [UIView animateWithDuration:kAnimationDuration animations:^{
        CGRect chatViewFrame = [self _getChatViewFrame:toInterfaceOrientation];
        [_chatView setFrame:chatViewFrame];
    } completion:NULL];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
}

#pragma mark - View Handler
- (CGRect)_getVideoViewFrame:(UIInterfaceOrientation)orientation {
    int smallerSide = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    return CGRectMake(0, [self _statusBarH], smallerSide/kVideoViewScale, smallerSide/kVideoViewScale);
}

- (CGRect)_getWhiteboardViewFrame:(UIInterfaceOrientation)orientation {
    CGRect bounds = self.view.bounds;
    
    return CGRectMake(0,
                      [self _statusBarH],
                      bounds.size.width,
                      bounds.size.height - [self _statusBarH]);
}

- (CGRect)_getChatViewFrame:(UIInterfaceOrientation)orientation {
    CGRect bounds = self.view.bounds;
    CGFloat chatViewFrameWidth;
    
    if (UIInterfaceOrientationIsPortrait(orientation))
        chatViewFrameWidth = bounds.size.width / 2;
    else
        chatViewFrameWidth = bounds.size.width / 4;
    
    return CGRectMake(bounds.size.width - chatViewFrameWidth,
                      [self _statusBarH],
                      chatViewFrameWidth,
                      bounds.size.height - [self _statusBarH]);
}

- (CGRect)_getCurrentPosLabelFrame:(UIInterfaceOrientation)orientation {
    CGRect bounds = self.view.bounds;
    
    return CGRectMake(0,
                      bounds.size.height - kProgressSliderBottom,
                      kProgressLabelW,
                      kProgressSliderH);
}

- (CGRect)_getDurationLabelFrame:(UIInterfaceOrientation)orientation {
    CGRect bounds = self.view.bounds;
    
    return CGRectMake(bounds.size.width - kProgressLabelW,
                      bounds.size.height - kProgressSliderBottom,
                      kProgressLabelW,
                      kProgressSliderH);
}

- (CGRect)_getProgressSliderFrame:(UIInterfaceOrientation)orientation {
    CGRect bounds = self.view.bounds;
    
    return CGRectMake(kProgressLabelW,
                      bounds.size.height - kProgressSliderBottom,
                      bounds.size.width - kProgressLabelW - kProgressLabelW,
                      kProgressSliderH);
}

- (CGRect)_getPlayButtonFrame:(UIInterfaceOrientation)orientation {
    CGRect bounds = self.view.bounds;
    
    return CGRectMake(kExitBtnW,
                      bounds.size.height - kPlayBtnH,
                      kPlayBtnW,
                      kPlayBtnH);
}

- (CGRect)_getExitButtonFrame:(UIInterfaceOrientation)orientation {
    CGRect bounds = self.view.bounds;
    
    return CGRectMake(0,
                      bounds.size.height - kExitBtnH,
                      kExitBtnW,
                      kExitBtnH);
}

#pragma mark - RecordedSession Delegation
- (void)onSessionStarted:(BOOL)success {
    _sessionInProcess = YES;
}

- (void)onSessionStopped {
    _sessionInProcess = NO;
}

- (void)onAnchorChanged:(NSString *)anchor {
    DDLogDebug(@"anchor: %@", anchor);
}

- (void)onMessage:(NSArray *)messages {
    [_chatView addChats:messages];
}

- (void)onClearAllMessages {
    [_chatView removeAllChats];
}

- (void)onSessionDuration:(long long)duration {
    DDLogDebug(@"duration: %lld", duration);
    _sessionDuration = duration;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _durationLabel.text = [self _formatTimeInterval:(int)duration/1000];
    });
}

- (void)onPositionChanged:(long long)position {
    dispatch_async(dispatch_get_main_queue(), ^{
        _currentPosLabel.text = [self _formatTimeInterval:(int)position/1000];
        float pos = 1.0 * [_currentPosLabel.text longLongValue] / [_durationLabel.text longLongValue];
        _progressSlider.value = pos;
    });
}

#pragma mark - Utilities
- (void)_showAlertWithTitle:(NSString *)title message:(NSString *)message {
    if ([UIAlertController class]) {    // NS_CLASS_AVAILABLE_IOS(8_0)
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        NSString *okButtonTitle = NSLocalizedString(@"OK", nil);
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)_moveViewToCorner:(UIView *)view fromPosition:(CGPoint)location {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        // Detect corner position
        CGRect topRightRect = CGRectMake(self.view.frame.size.width / 2., 0, self.view.frame.size.width / 2., self.view.frame.size.height / 2.);
        CGRect bottomLeftRect = CGRectMake(0, self.view.frame.size.height / 2., self.view.frame.size.width / 2., self.view.frame.size.height / 2.);
        CGRect bottomRightRect = CGRectMake(self.view.frame.size.width / 2., self.view.frame.size.height / 2., self.view.frame.size.width / 2., self.view.frame.size.height / 2.);
        
        CGFloat centerW = view.bounds.size.width / 2.;
        CGFloat centerH = view.bounds.size.height / 2.;
        
        if (CGRectContainsPoint(topRightRect, location)) {
            view.center = CGPointMake(self.view.frame.size.width - centerW, centerH + [self _statusBarH]);
            view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            
        } else if (CGRectContainsPoint(bottomLeftRect, location)) {
            view.center = CGPointMake(centerW, self.view.frame.size.height - centerH);
            view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            
        } else if (CGRectContainsPoint(bottomRightRect, location)) {
            view.center = CGPointMake(self.view.frame.size.width - centerW, self.view.frame.size.height - centerH);
            view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            
        } else {
            view.center = CGPointMake(centerW, centerH + [self _statusBarH]);
            view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
    }];
}

- (CGFloat)_statusBarH {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation))
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    else
        return [UIApplication sharedApplication].statusBarFrame.size.width;
}

- (NSString *)_formatTimeInterval:(int)seconds {
    seconds = MAX(0, seconds);
    
    int s = seconds;
    int m = s / 60;
    //int h = m / 60;
    
    s = s % 60;
    //m = m % 60;
    
    return [NSString stringWithFormat:@"%0.2d:%0.2d", m ,s];
}

@end
