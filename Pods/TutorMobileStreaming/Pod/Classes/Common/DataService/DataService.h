//
//  DataService.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/8.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RtmpService.h"
#import "TutorConsoleService.h"

typedef enum _SessionMusic {
    SessionMusic_None,
    SessionMusic_Start10Min,
    SessionMusic_Start3Min,
    SessionMusic_StartNow,
    SessionMusic_End,
    SessionMusic_Clap,
} SessionMusic;

@protocol DataServiceDelegate <NSObject>
- (void)onConnected;
- (void)onAnchorChanged:(NSString *)anchor; // cohost, coordinator
- (void)onUserIn:(NSString *)userName publishName:(NSString *)publishName role:(NSString *)role isLobbySession:(BOOL)isLobbySession;
- (void)onUserOut:(NSString *)userName;
- (void)onMessage:(NSArray *)messagAray;    // array of dictionary of userName, message and receiver
- (void)onPlayMusic:(SessionMusic)music;
- (void)onClapHands:(NSString *)userName;
- (void)onConsultantLost:(NSString *)consultant;
- (void)onSendWaitMsg;
- (void)onMicMute:(BOOL)mute;
- (void)onHelpMessage:(NSString *)messageId msgIdx:(int)msgIdx status:(HelpMsgStatus)status;
- (void)onSpkrVolChanged:(int)vol;      // 0 ~ 10
- (void)onMicGainChanged:(int)gain;     // 0 ~ 100
- (void)onDisableVideo:(int)disable userName:(NSString *)userName;
- (void)onDisableChat:(int)disable userName:(NSString *)userName;
- (void)onRelogin;
- (void)onAdminMessage:(NSString *)msg;
- (void)onExitApp;  // server found that there is a duplicated user logged in another device

// Whiteboard
- (void)onWhiteboardPageChanged:(int)pageIdx;   // start from 0
- (void)onWhiteboardTotalPages:(int)totalPages;
- (void)onWhiteboardResetWebPointer;
- (void)onWhiteboardResetWebMouse;
- (void)onWhiteboardWebPointerChange:(CGPoint)point;
- (void)onWhiteboardWebMouseChange:(CGPoint)point;
- (void)onWhiteboardObjectAdded:(WhiteboardObject *)wbObject;
- (void)onWhiteboardObjectUpdated:(WhiteboardObject *)wbObject;
- (void)onWhiteboardObjectRemoved:(int)objId;
@end

@interface DataService : RtmpService
- (id)initWithUrl:(NSString *)url delegate:(id<DataServiceDelegate>)delegate userParams:(NSDictionary *)userParams;

// Session related
- (void)sendLoginEvent:(NSString *)event;
- (void)sendLogoutEvent:(NSString *)event;
- (void)sendLog:(NSDictionary *)logContents;

// User related
- (void)clapHands:(NSString *)userName;

// Chat related methods
- (void)sendMessage:(NSString *)message
           userName:(NSString *)userName
        senderLabel:(NSString *)senderLabel
           receiver:(NSString *)receiver
      receiverLabel:(NSString *)receiverLabel;
- (void)talkToConsultatnt:(NSString *)messageIndex
                 userName:(NSString *)userName;

// Whiteboard related methods
- (void)switchWhiteboardPageTo:(int)toPageIdx from:(int)fromPageIdx;

// Device related methods
- (void)setSystemInfo:(NSString *)os userName:(NSString *)userName;
- (void)setSpeakerVolume:(int)vol;      // 0 ~ 10
- (void)setMicrophoneGain:(int)gain;    // 0 ~ 100
- (void)setMicrophoneMute:(BOOL)mute;
@end
