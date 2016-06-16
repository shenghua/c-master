//
//  RtmpService.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/2.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "RtmpService.h"
#import "librtmp/log.h"
#import "TutorLog.h"
#import "UrlUtility.h"

#define LOG_BUF_SIZE 65535

@interface RtmpService()
@property (nonatomic, assign) RTMP *rtmp;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL interrupted;
@end

@implementation RtmpService

void _rtmpLog(int level, const char *fmt, va_list args) {
    @autoreleasepool {
        char buffer[LOG_BUF_SIZE];
        vsnprintf(buffer, LOG_BUF_SIZE, fmt, args);
        NSString *log = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
        
        DDLogDebug(@"%@", log);
    }
}

void _rtmpCallback(RtmpCallbackType cbType, void *userData, void *cbData) {
    [(__bridge RtmpService *)userData rtmpCallback:cbType userData:userData cbData:cbData];
}

- (id)initWithUrl:(NSString *)url userParams:(NSDictionary *)userParams {
    if (self = [super init]) {
        RTMP_LogSetLevel(RTMP_LOGCRIT);
//        RTMP_LogSetCallback(_rtmpLog);
        
        _url = url;
        _userParams = [NSDictionary dictionaryWithDictionary:userParams];
        
        _logService = [[LogService alloc] initWithSessionSn:_userParams[@"sessionSn"]
                                                     userSn:_userParams[@"userSn"]
                                                   userType:_userParams[@"userType"]
                                                   userName:_userParams[@"userName"]
                                                 compStatus:_userParams[@"compStatus"]];
    }
    return self;
}

- (BOOL)connect {
    if (!_rtmp) {
        DDLogDebug(@"connect begin: %@", _url);
         _interrupted = NO;
        _rtmp = RTMP_Alloc();
        RTMP_Init(_rtmp);
        RTMP_SetCallback(_rtmp, _rtmpCallback, (__bridge void *)self);
        RTMP_EnableDataMode(_rtmp);
        
        char *rtmpUrl = (char *)[_url cStringUsingEncoding:NSUTF8StringEncoding];
        
        if (RTMP_SetupURL(_rtmp, rtmpUrl) && RTMP_Connect(_rtmp, NULL)) {
            if (RTMP_IsConnected(_rtmp)) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    DDLogDebug(@"ReadPacketLoop Start");
                    
                    RTMPPacket packet = { 0 };
                    while (_rtmp) {
                        if (_interrupted)
                            break;
                        
                        @synchronized(self) {
                            if (RTMP_IsConnected(_rtmp) && RTMP_ReadPacket(_rtmp, &packet)) {
                                if (RTMPPacket_IsReady(&packet)) {
                                    if (!packet.m_nBodySize)
                                        continue;
                                    
                                    RTMP_ClientPacket(_rtmp, &packet);
                                    RTMPPacket_Free(&packet);
                                }
                            }
                            else {
                                DDLogDebug(@"RTMP_ReadPacket failed");
                                break;
                            }
                        }
                    }
                    
                    DDLogDebug(@"ReadPacketLoop End");
                });
                
                DDLogDebug(@"Connect end, success !!");
                return YES;
            }
        }
        
        [self disconnect];
        
        DDLogDebug(@"Connect end, fail !!");
        return NO;
    }
    
    return YES;
}

- (void)disconnect {
    if (_rtmp) {
        DDLogDebug(@"disconnect begin");
        
        RTMP_SetCallback(_rtmp, NULL, (__bridge void *)self);
        RTMP_Close(_rtmp);
        
        _interrupted = YES;
        @synchronized(self) {
            RTMP_Free(_rtmp);
            _rtmp = NULL;
        }
        
        DDLogDebug(@"disconnect end");
    }
}

- (void)rtmpCallback:(RtmpCallbackType)cbType userData:(void *)userData cbData:(void *)cbData {
    NSAssert(NO, @"No implementation of rtmpCallback");
}

#pragma mark - Utilities
- (void)connectSharedObject:(NSString *)so flag:(int)flag {
    if (_rtmp && so) {
        RTMP_SendConnectSharedObject(_rtmp, [so cStringUsingEncoding:NSUTF8StringEncoding], flag);
    }
}

- (void)disconnectSharedObject:(NSString *)so flag:(int)flag {
    if (_rtmp && so) {
        RTMP_SendDisconnectSharedObject(_rtmp, [so cStringUsingEncoding:NSUTF8StringEncoding], flag);
    }
}

- (void)invokeCmd:(RtmpCmd)cmd params:(void *)params {
    if (!_rtmp) {
        return;
    }
    
    switch (cmd) {
        case RtmpCmd_GetAnchor:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_GET_ANCHOR, NULL);
            break;
            
        case RtmpCmd_SendMessage:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_SEND_MSG, params);
            break;
            
        case RtmpCmd_TalkToCustSupt:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_TALK_TO_CUSTSUPT, params);
            break;
            
        case RtmpCmd_TalkToConsultant:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_TALK_TO_CONSULTANT, params);
            break;
            
        case RtmpCmd_ClapHands:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_CLAP_HANDS, params);
            break;
            
        case RtmpCmd_GetChatHistory:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_GET_CHAT_HISTORY, NULL);
            break;
            
        case RtmpCmd_InvokeCmdFromString:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_FROM_STRING, params);
            break;
            
        case RtmpCmd_SetSpeakerVol:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_SET_SPEAKER_VOL, params);
            break;
            
        case RtmpCmd_SetMicGain:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_SET_MIC_GAIN, params);
            break;

        case RtmpCmd_SetMicMute:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_SET_MIC_MUTE, params);
            break;
            
        case RtmpCmd_SetSysInfo:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_SET_SYS_INFO, params);
            break;
            
        case RtmpCmd_SendLoginEvent:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_SEND_LOGIN_EVENT, params);
            break;

        case RtmpCmd_SendLogoutEvent:
            RTMP_InvokeCmd(_rtmp, RTMP_INVOKE_CMD_SEND_LOGOUT_EVENT, params);
            break;
            
        default:
            break;
    }
}

- (NSString *)getUserNameWithoutTilde {
    NSString *name = _userParams[@"userName"];
    NSRange range = [name rangeOfString:@"~"];
    if (range.location != NSNotFound)
        name = [name substringToIndex:range.location];
    
    return name;
}

- (BOOL)isLobbySession {
    NSString *val = _userParams[@"lobbySession"];
    if (val && [val caseInsensitiveCompare:@"true"] == NSOrderedSame)
        return YES;
    else
        return NO;
}

- (BOOL)isGlassSession {
    NSString *val = _userParams[@"glassSession"];
    if (val && [val caseInsensitiveCompare:@"true"] == NSOrderedSame)
        return YES;
    else
        return NO;
}

@end
