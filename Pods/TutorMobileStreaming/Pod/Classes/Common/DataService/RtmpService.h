//
//  RtmpService.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/2.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "librtmp/rtmp.h"
#import "LogService.h"

#define kWebinarUsersSo @"webinar_users_so"
#define kUsersSo @"users_so"
#define kVideoSo @"video_so"
#define kChatSo @"chat_so"

typedef enum _RtmpCmd {
    RtmpCmd_GetAnchor,
    RtmpCmd_SendMessage,
    RtmpCmd_TalkToConsultant,
    RtmpCmd_TalkToCustSupt,
    RtmpCmd_ClapHands,
    RtmpCmd_GetChatHistory,
    RtmpCmd_InvokeCmdFromString,
    RtmpCmd_SetSpeakerVol,
    RtmpCmd_SetMicGain,
    RtmpCmd_SetMicMute,
    RtmpCmd_SetSysInfo,
    RtmpCmd_SendLoginEvent,
    RtmpCmd_SendLogoutEvent,
} RtmpCmd;

@interface RtmpService : NSObject
@property (nonatomic, strong) NSDictionary *userParams;
@property (nonatomic, strong) LogService *logService;

// The following method must be implemented by subclass
- (void)rtmpCallback:(RtmpCallbackType)cbType userData:(void *)userData cbData:(void *)cbData;

// Protected methods
- (void)connectSharedObject:(NSString *)so flag:(int)flag;
- (void)disconnectSharedObject:(NSString *)so flag:(int)flag;
- (void)invokeCmd:(RtmpCmd)cmd params:(void *)params;
- (NSString *)getUserNameWithoutTilde;
- (BOOL)isLobbySession;
- (BOOL)isGlassSession;

// Public methods
- (id)initWithUrl:(NSString *)url userParams:(NSDictionary *)userParams;
- (BOOL)connect;
- (void)disconnect;

@end
