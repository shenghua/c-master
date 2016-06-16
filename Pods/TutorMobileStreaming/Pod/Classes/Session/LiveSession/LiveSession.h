//
//  LiveSession.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/25.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Streamer.h"
#import "Player.h"
#import "DataService.h"
#import "TutorConsoleService.h"
#import "SessionChatMessage.h"
#import "LiveWhiteboard.h"

@protocol LiveSessionDelegate <NSObject>
@required

@optional
- (void)onSessionStarted:(BOOL)success;
- (void)onSessionStopped;
- (void)onAnchorChanged:(NSString *)anchor;
- (void)onUserIn:(NSString *)userName role:(NSString *)role;
- (void)onUserOut:(NSString *)userName;
- (void)onNoFrameGot:(NSString *)userName;    // no audio/video frames coming for a specific time
- (void)onMessage:(NSArray<SessionChatMessage *> *)messages;
- (void)onConsultantLost:(NSString *)consultant;
- (void)onSendWaitMsg;
- (void)onMicMute:(BOOL)mute;           // request from server, upper layer needs to decide if need to setMicrophoneGain or not
- (void)onMicGainChanged:(float)vol;    // 0 ~ 1, request from server, upper layer needs to decide if need to setMicrophoneGain or not
- (void)onDisableVideo:(int)disable;    // request from server, upper layer needs to decide if need to disable video or not
- (void)onDisableChat:(int)disable;     // request from server, upper layer needs to decide if need to disable chat or not
- (void)onHelpMessage:(NSNumber *)msgIdx status:(HelpMsgStatus)status;
- (void)onRelogin;                      // request from server, upper layer needs to decide if need to relogin or not
- (void)onAdminMessage:(NSString *)msg; // request from server, upper layer needs to decide if need to show admin message or not
- (void)onAdminMessageReconnectServer:(NSString *)newServerIp newRelayIp:(NSString *)newRelayIp; // request from server, upper layer needs to decide if need to restart session with new ip or not
- (void)onExitApp;  // server found that there is a duplicated user logged in another device, upper layer needs to decide if need to logout or not

- (void)onWhiteboardPageChanged:(int)pageIdx;   // start from 0
- (void)onWhiteboardTotalPages:(int)totalPages;
// The following onWhiteboard methods will be invoked if upper layer doesn't provide whiteboard view for Session
- (void)onWhiteboardResetWebPointer;
- (void)onWhiteboardResetWebMouse;
- (void)onWhiteboardWebPointerChange:(CGPoint)point;
- (void)onWhiteboardWebMouseChange:(CGPoint)point;
- (void)onWhiteboardObjectAdded:(WhiteboardObject *)wbObject;
- (void)onWhiteboardObjectUpdated:(WhiteboardObject *)wbObject;
- (void)onWhiteboardObjectRemoved:(int)objId;

- (void)onVideoFps:(int)fps;
- (void)onPositionChanged:(long long)position;   // milliseconds
@end

@interface LiveSession : NSObject <StreamerDelegate, PlayerDelegate, DataServiceDelegate, TutorConsoleServiceDelegate, WhiteboardDelegate>
@property (nonatomic, assign) BOOL enableVPN;
@property (nonatomic, assign) BOOL enableRelay;
@property (nonatomic, weak) id<LiveSessionDelegate> delegate;
@property (nonatomic, strong) NSString *anchor;                   // Store the current anchor (coordinator or cohost), default is coordinator
@property (nonatomic, strong) NSString *shortUserName;
@property (nonatomic, assign) float defaultUserVolumeFactor;       // The volume factor will be applied when new user coming

- (instancetype)initSessionWithClassInfo:(NSDictionary *)classInfo
                                delegate:(id<LiveSessionDelegate>)delegate
                            streamerView:(UIView *)streamerView
                          consultantView:(UIView *)consultantView
                          whiteboardView:(UIView *)whiteboardView;
- (void)startSession;
- (void)stopSession;

// User related methods
- (void)reconnectUser:(NSString *)userName;     // Will send onUserOut and then onUserIn after connection is established
- (void)connectUser:(NSString *)userName;       // Will send onUserIn after connection is established
- (void)disconnectUser:(NSString *)userName;    // Will send onUserOut after connection is established

// Chat related methods
- (void)sendMessageToAll:(NSString *)message;                           // Send message to all users
- (void)sendMessageToConsultatnt:(NSString *)message msgIndex:(int)index;   // Send message to the current anchor, index: starting from 1
- (void)sendMessageToIT:(NSString *)message;                            // Send message to IT
- (void)sendHelpMessage:(NSString *)message msgIdx:(NSNumber *)msgIdx;  // Send help message to IT
- (void)confirmHelpMsg:(NSNumber *)msgIdx confirmed:(HelpMsgConfirmed)confirmed;  // Send confirmed message to IT
- (void)clapHands;                                                      // Send clap hands message to all users

// Microphone related methods
- (void)setMicrophoneGain:(float)gain;  // 0 ~ 1    (Still can hear little sound when setting gain to 0)
- (float)getMicrophoneGain;
- (void)setMicrophoneMute:(BOOL)mute;
- (BOOL)getMicrophoneMute;

// Volume related methods
- (void)setUserVolumeFactor:(float)vol userName:(NSString *)userName;;
- (float)getUserVolumeFactor:(NSString *)userName;

// Whiteboard related methods
- (void)switchWhiteboardPage:(int)pageIdx;

// Streamer
- (void)setCameraPosition:(CameraPosition)position;
- (CameraPosition)getCameraPosition;
@end
