//
//  LiveSessionRoomViewController.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/6/23.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "LiveSessionRoomViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "ChatButton.h"
#import "TutorLog.h"
#import "DeviceUtility.h"
 #import <MediaPlayer/MediaPlayer.h>

#define kVideoViewScale 2
#define kAnimationDuration 0.2

#define kSendMsgBtnH   30.0
#define kSendMsgBtnW   40.0

#define kExitBtnH   40.0
#define kExitBtnW   40.0

#define kSpaceBetweenTextFieldAndKeyboard 5     // Space between textfield and the keyboard
#define kTranslateDuration 0.1                  // Translation duration of view

@interface LiveSessionRoomViewController ()
@property (nonatomic, strong) LiveSession *session;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) ChatView *chatView;
@property (nonatomic, strong) UIView *whiteboardView;

@property (nonatomic, strong) UITextField *msgTextFiled;
@property (nonatomic, strong) ChatButton  *sendMsgButton;
@property (nonatomic, assign) UITextField *activeTextField;
@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) MPVolumeView *volumeView;     // Control device's speaker volume
@end

@implementation LiveSessionRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init session
    _session = [[LiveSession alloc] initSessionWithClassInfo:self.classInfo delegate:self streamerView:nil consultantView:_videoView whiteboardView:_whiteboardView];
    
    // Set up gesture for video view
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_moveViewWithGestureRecognizer:)];
    [_videoView addGestureRecognizer:panGestureRecognizer];
    
    // Hide navigation bar
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    // Init volumeView
    _volumeView = [[MPVolumeView alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    // Register for keyboard notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    // Start session
    [_session startSession];
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
    
    // Create message text field
    CGRect messageTextFieldFrame = [self _getMessageTextFieldFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadMessageTextField:messageTextFieldFrame];
    
    // Create send button
    CGRect sendMsgButtonFrame = [self _getSendMsgButtonFrame:[UIApplication sharedApplication].statusBarOrientation];
    [self _loadSendMsgButton:sendMsgButtonFrame];
    
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

- (void)_loadMessageTextField:(CGRect)frame {
    _msgTextFiled = [[UITextField alloc] initWithFrame:frame];
    _msgTextFiled.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    _msgTextFiled.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    _msgTextFiled.delegate = self;
    
    [self.view addSubview:_msgTextFiled];
}

- (void)_loadSendMsgButton:(CGRect)frame {
    _sendMsgButton = [[ChatButton alloc] initWithFrame:frame];
    _sendMsgButton.backgroundColor = [UIColor brownColor];
    _sendMsgButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [_sendMsgButton setTitle:@"Send" forState:UIControlStateNormal];
    _sendMsgButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_sendMsgButton addTarget:self action:@selector(_sendMsgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_sendMsgButton];
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

- (void)_sendMsgButtonClicked:(UIButton *)sender {
    if (!_session)
        return;
    
    if (![_msgTextFiled.text isEqualToString:@""]) {
        [_session sendMessageToAll:_msgTextFiled.text];
        
        // Clear text
        [_msgTextFiled setText:@""];
    }
    
    // Hide keyboard
    [_msgTextFiled resignFirstResponder];
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
        
        CGRect messageTextFieldFrame = [self _getMessageTextFieldFrame:toInterfaceOrientation];
        [_msgTextFiled setFrame:messageTextFieldFrame];
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
                      bounds.size.height - [self _statusBarH] - kSendMsgBtnH);
}

- (CGRect)_getMessageTextFieldFrame:(UIInterfaceOrientation)orientation {
    CGRect chatViewFrame = [self _getChatViewFrame:orientation];
    
    return CGRectMake(chatViewFrame.origin.x,
                      chatViewFrame.origin.y + chatViewFrame.size.height,
                      chatViewFrame.size.width - kSendMsgBtnW,
                      kSendMsgBtnH);
}

- (CGRect)_getSendMsgButtonFrame:(UIInterfaceOrientation)orientation {
    CGRect chatViewFrame = [self _getChatViewFrame:orientation];
    
    return CGRectMake(chatViewFrame.origin.x + chatViewFrame.size.width - kSendMsgBtnW,
                      chatViewFrame.origin.y + chatViewFrame.size.height,
                      kSendMsgBtnW,
                      kSendMsgBtnH);
}

- (CGRect)_getExitButtonFrame:(UIInterfaceOrientation)orientation {
    CGRect bounds = self.view.bounds;
    
    return CGRectMake(0,
                      bounds.size.height - kExitBtnH,
                      kExitBtnW,
                      kExitBtnH);
}

#pragma mark - Session Delegation
- (void)onNoFrameGot:(NSString *)userName {
    if (_session)
        [_session reconnectUser:userName];
}

- (void)onSessionStarted:(BOOL)success {
    DDLogDebug(@"onSessionStarted: %d", success);
}

- (void)onSessionStopped {
    DDLogDebug(@"onSessionStopped");
}

- (void)onMicGainChanged:(float)gain {
    if (_session)
        [_session setMicrophoneGain:gain];
}

- (void)onMicMute:(BOOL)mute {
    if (_session)
        [_session setMicrophoneMute:mute];
}

- (void)onAnchorChanged:(NSString *)anchor {
    DDLogDebug(@"anchor: %@", anchor);
}

- (void)onMessage:(NSArray *)messages {
    [_chatView addChats:messages];
}

- (void)onHelpMessage:(NSNumber *)msgIdx status:(HelpMsgStatus)status {
    if (status == HelpMsgStatus_Done)
        [_session confirmHelpMsg:msgIdx confirmed:HelpMsgConfirmed_Yes];
}

- (void)onDisableVideo:(int)disable {
    dispatch_async(dispatch_get_main_queue(), ^{
        _videoView.hidden = disable;
    });
}

- (void)onDisableChat:(int)disable {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (disable)
            [_msgTextFiled resignFirstResponder];
        _msgTextFiled.enabled = !disable;
        _sendMsgButton.enabled = !disable;
    });
}

- (void)onSendWaitMsg {
    if (_chatView) {
        NSDateFormatter *curTimeFormatter = [[NSDateFormatter alloc] init];
        NSString *time = [curTimeFormatter stringFromDate:[NSDate date]];
        SessionChatMessage *mesg = [[SessionChatMessage alloc] initWithUserName:@"IT"
                                                                           time:time
                                                                        message:@"Dear customers: Please do not leave the classroom. Consultants are about to enter the classroom. Thank you for your patience."
                                                                       priority:SessionChatMessagePriority_High];
        [_chatView addChats:@[mesg]];
    }
}

- (void)onExitApp {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.navigationController popViewControllerAnimated:YES];
//    });
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

#pragma mark - Notification Handling
- (void)keyboardWillShow:(NSNotification *)notification {
    _keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self updateViewPosition];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardFrame = CGRectNull;
    [self updateViewPosition];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)translateView:(UIView*)view toRect:(CGRect)rect withDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {
        // stub
    }];
}

- (void)updateViewPosition {
    if (_activeTextField && !CGRectIsNull(_keyboardFrame)) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGRect localKeyboardFrame = [window convertRect: _keyboardFrame toView:self.view];
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y = 0;
        
        if (CGRectGetMaxY(_activeTextField.frame) + kSpaceBetweenTextFieldAndKeyboard > CGRectGetMinY(localKeyboardFrame)) {
            viewFrame.origin.y = -1.0 * (CGRectGetMaxY(_activeTextField.frame) + kSpaceBetweenTextFieldAndKeyboard - CGRectGetMinY(localKeyboardFrame));
        }
        
        [self translateView:self.view toRect:viewFrame withDuration:kTranslateDuration];
    } else {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y = 0;
        [self translateView:self.view toRect:viewFrame withDuration:kTranslateDuration];
    }
}

@end
