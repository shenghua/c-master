//
//  DataService.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/8.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "SessionChatMessage.h"
#import "DataService.h"
#import "TutorLog.h"
#import "WbObjectFactory.h"
#import "HttpRequestUtility.h"
#import "SessionConstants.h"

#define kGlassAddChatUrl @"http://resapi.tutorabc.com:3000/chat/AddChat"

@interface DataService()
@property (nonatomic, weak) id<DataServiceDelegate> delegate;
@end

@implementation DataService

- (id)initWithUrl:(NSString *)url delegate:(id<DataServiceDelegate>)delegate userParams:(NSDictionary *)userParams {
    if (self = [super initWithUrl:url userParams:userParams]) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - librtmp Callback Handler
- (void)rtmpCallback:(RtmpCallbackType)cbType userData:(void *)userData cbData:(void *)cbData {
    switch (cbType) {
        case RtmpCallbackType_Connected:
            DDLogDebug(@"RtmpCallbackType_Connected");
            [(__bridge DataService *)userData _executePostConnectedTasks];
            
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onConnected)]) {
                
                [[(__bridge DataService *)userData delegate] onConnected];
            }
            break;
            
        case RtmpCallbackType_AnchorChanged:
            // Anchor: 1 (coordinator), 2 (cohost)
            DDLogDebug(@"RtmpCallbackType_AnchorChanged: %d", *((int *)cbData));
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onAnchorChanged:)]) {
                
                if (*((int *)cbData) == 1)
                    [[(__bridge DataService *)userData delegate] onAnchorChanged:@"coordinator"];
                else if (*((int *)cbData) == 2)
                    [[(__bridge DataService *)userData delegate] onAnchorChanged:@"cohost"];
            }
            break;
            
        case RtmpCallbackType_UserIn:
            DDLogDebug(@"RtmpCallbackType_UserIn: userName (%s), publishName (%s), role (%s), isLobbySession(%d)",
                       ((UserIn *)cbData)->userName,
                       ((UserIn *)cbData)->publishName,
                       ((UserIn *)cbData)->role,
                       ((UserIn *)cbData)->isLobbySession);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onUserIn:publishName:role:isLobbySession:)]) {
                
                [[(__bridge DataService *)userData delegate] onUserIn:[NSString stringWithUTF8String:((UserIn *)cbData)->userName]
                                                          publishName:[NSString stringWithUTF8String:((UserIn *)cbData)->publishName]
                                                                 role:[NSString stringWithUTF8String:((UserIn *)cbData)->role]
                                                       isLobbySession:((UserIn *)cbData)->isLobbySession];
            }
            break;
            
        case RtmpCallbackType_UserOut:
            DDLogDebug(@"RtmpCallbackType_UserOut: userName (%s)", (char *)cbData);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onUserOut:)]) {
                
                [[(__bridge DataService *)userData delegate] onUserOut:[NSString stringWithUTF8String:(char *)cbData]];
            }
            break;
            
        case RtmpCallbackType_Message:
        {
            DDLogDebug(@"RtmpCallbackType_Message");
            Message *message = (Message *)cbData;
            NSMutableArray *messageArray = [NSMutableArray new];
            while (message) {
                if (message->userTime && message->message && [NSString stringWithUTF8String:message->message] && message->receiver)
                    [messageArray addObject:@{@"userTime": [NSString stringWithUTF8String:message->userTime],
                                              @"message": [NSString stringWithUTF8String:message->message],
                                              @"receiver": [NSString stringWithUTF8String:message->receiver]}];
                message = message->next;
                
//                DDLogDebug(@"RtmpCallbackType_Message: %@", messageArray);
            }
            
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onMessage:)]) {
                
                [[(__bridge DataService *)userData delegate] onMessage:messageArray];
            }
            break;
        }
            
        case RtmpCallbackType_PlaySessionStart10MinMusic:
            DDLogDebug(@"RtmpCallbackType_PlaySessionStart10MinMusic");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onPlayMusic:)]) {
                
                [[(__bridge DataService *)userData delegate] onPlayMusic:SessionMusic_Start10Min];
            }
            break;
            
        case RtmpCallbackType_PlaySessionStart3MinMusic:
            DDLogDebug(@"RtmpCallbackType_PlaySessionStart3MinMusic");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onPlayMusic:)]) {
                
                [[(__bridge DataService *)userData delegate] onPlayMusic:SessionMusic_Start3Min];
            }
            break;
            
        case RtmpCallbackType_PlaySessionStartNowMusic:
            DDLogDebug(@"RtmpCallbackType_PlaySessionStartNowMusic");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onPlayMusic:)]) {
                
                [[(__bridge DataService *)userData delegate] onPlayMusic:SessionMusic_StartNow];
            }
            break;
            
        case RtmpCallbackType_PlaySessionEndMusic:
            DDLogDebug(@"RtmpCallbackType_PlaySessionEndMusic");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onPlayMusic:)]) {
                
                [[(__bridge DataService *)userData delegate] onPlayMusic:SessionMusic_End];
            }
            break;
            
        case RtmpCallbackType_ClapHandsFromSrvr:
            DDLogDebug(@"RtmpCallbackType_ClapHandsFromSrvr: userName (%s)", (char *)cbData);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onClapHands:)]) {
                
                [[(__bridge DataService *)userData delegate] onClapHands:[NSString stringWithUTF8String:(char *)cbData]];
            }
            break;
            
        case RtmpCallbackType_ConsultantLostFromSvr:
            DDLogDebug(@"RtmpCallbackType_ConsultantLostFromSvr: consultant (%s)", (char *)cbData);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onConsultantLost:)]) {
                
                [[(__bridge DataService *)userData delegate] onConsultantLost:[NSString stringWithUTF8String:(char *)cbData]];
            }
            break;
            
        case RtmpCallbackType_SendWaitMsgFromSrvr:
            DDLogDebug(@"RtmpCallbackType_SendWaitMsgFromSrvr");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onSendWaitMsg)]) {
                
                [[(__bridge DataService *)userData delegate] onSendWaitMsg];
            }
            break;
            
        case RtmpCallbackType_NoSpeakFromSrvr:
            DDLogDebug(@"RtmpCallbackType_NoSpeakFromSrvr");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onMicMute:)]) {
                
                [[(__bridge DataService *)userData delegate] onMicMute:YES];
            }
            break;
            
        case RtmpCallbackType_SpeakFromSrvr:
            DDLogDebug(@"RtmpCallbackType_SpeakFromSrvr");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onMicMute:)]) {
                
                [[(__bridge DataService *)userData delegate] onMicMute:NO];
            }
            break;
        
        case RtmpCallbackType_SetSpkrVolFromSrvr:
            DDLogDebug(@"RtmpCallbackType_SetSpkrVolFromSrvr: %d", *((int *)cbData));
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onSpkrVolChanged:)]) {
                
                [[(__bridge DataService *)userData delegate] onSpkrVolChanged:*((int *)cbData)];
            }
            break;
            
        case RtmpCallbackType_SetMicGainFromSrvr:
            DDLogDebug(@"RtmpCallbackType_SetMicGainFromSrvr: %d", *((int *)cbData));
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onMicGainChanged:)]) {
                
                [[(__bridge DataService *)userData delegate] onMicGainChanged:*((int *)cbData)];
            }
            break;
            
        case RtmpCallbackType_HelpMsgConfirmFromSrvr:
            DDLogDebug(@"RtmpCallbackType_HelpMsgConfirmFromSrvr: status (%d)", ((ConfirmedHelpMessage *)cbData)->status);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onHelpMessage:msgIdx:status:)]) {
                
                [[(__bridge DataService *)userData delegate] onHelpMessage:[NSString stringWithUTF8String:((ConfirmedHelpMessage *)cbData)->msgId]
                                                                    msgIdx:-1
                                                                    status:((ConfirmedHelpMessage *)cbData)->status];
            }
            break;
            
        case RtmpCallbackType_DisableVideoFromSrv:
            DDLogDebug(@"RtmpCallbackType_DisableVideoFromSrv: userName (%s), disable (%d)", ((DisableVideo *)cbData)->userName, ((DisableVideo *)cbData)->disable);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onDisableVideo:userName:)]) {
                
                [[(__bridge DataService *)userData delegate] onDisableVideo:((DisableVideo *)cbData)->disable
                                                                   userName:[NSString stringWithUTF8String:((DisableVideo *)cbData)->userName]];
            }
            break;
        
        case RtmpCallbackType_DisableChatFromSrv:
            DDLogDebug(@"RtmpCallbackType_DisableChatFromSrv: userName (%s), disable (%d)", ((DisableChat *)cbData)->userName, ((DisableChat *)cbData)->disable);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onDisableChat:userName:)]) {
                
                [[(__bridge DataService *)userData delegate] onDisableChat:((DisableChat *)cbData)->disable
                                                                   userName:[NSString stringWithUTF8String:((DisableChat *)cbData)->userName]];
            }
            break;
        
        case RtmpCallbackType_ReloginFromSrvr:
            DDLogDebug(@"RtmpCallbackType_ReloginFromSrvr");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onRelogin)]) {
                
                [[(__bridge DataService *)userData delegate] onRelogin];
            }
            break;
        
        case RtmpCallbackType_OnAdminMessage:
            DDLogDebug(@"RtmpCallbackType_OnAdminMessage: %s", (char *)cbData);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onAdminMessage:)]) {
                
                [[(__bridge DataService *)userData delegate] onAdminMessage:[NSString stringWithUTF8String:(char *)cbData]];
            }
            break;
            
        case RtmpCallbackType_Whiteboard_CurrentPage:
            DDLogDebug(@"RtmpCallbackType_Whiteboard_CurrentPage: %d", *((int *)cbData));
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardPageChanged:)]) {
                
                [[(__bridge DataService *)userData delegate] onWhiteboardPageChanged:*((int *)cbData)];
            }
            break;
            
        case RtmpCallbackType_Whiteboard_TotalPages:
            DDLogDebug(@"RtmpCallbackType_Whiteboard_TotalPages: %d", *((int *)cbData));
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardTotalPages:)]) {
                
                [[(__bridge DataService *)userData delegate] onWhiteboardTotalPages:*((int *)cbData)];
            }
            break;
        
        case RtmpCallbackType_ResetWebPointerFromSrvr:
            DDLogDebug(@"RtmpCallbackType_ResetWebPointerFromSrvr");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardResetWebPointer)]) {
                
                [[(__bridge DataService *)userData delegate] onWhiteboardResetWebPointer];
            }
            break;
        
        case RtmpCallbackType_ResetWebMouseFromSrvr:
            DDLogDebug(@"RtmpCallbackType_ResetWebMouseFromSrvr");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardResetWebMouse)]) {
                
                [[(__bridge DataService *)userData delegate] onWhiteboardResetWebMouse];
            }
            break;
            
        case RtmpCallbackType_WebPointerFromSrvr:
            DDLogDebug(@"RtmpCallbackType_WebPointerFromSrvr: userName (%s), x (%d), y (%d)", ((WebPointer *)cbData)->userName, ((WebPointer *)cbData)->x, ((WebPointer *)cbData)->y);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardWebPointerChange:)]) {
                
                [[(__bridge DataService *)userData delegate] onWhiteboardWebPointerChange:CGPointMake(((WebPointer *)cbData)->x, ((WebPointer *)cbData)->y)];
            }
            break;
        
        case RtmpCallbackType_WebMouseFromSrvr:
            DDLogDebug(@"RtmpCallbackType_WebMouseFromSrvr: userName (%s), x (%d), y (%d)", ((WebPointer *)cbData)->userName, ((WebPointer *)cbData)->x, ((WebPointer *)cbData)->y);
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardWebMouseChange:)]) {
                
                [[(__bridge DataService *)userData delegate] onWhiteboardWebMouseChange:CGPointMake(((WebPointer *)cbData)->x, ((WebPointer *)cbData)->y)];
            }
            break;
        
        case RtmpCallbackType_Whiteboard_ObjectChange:
        {
            DDLogDebug(@"RtmpCallbackType_Whiteboard_ObjectChange: objId (%d), shape (%d)", ((WhiteboardObject *)cbData)->objId ,((WhiteboardObject *)cbData)->shape);
            
            if ([(__bridge DataService *)userData delegate]) {
                
                if (((WhiteboardObject *)cbData)->shape != WhiteboardShape_NoShape &&
                    [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardObjectAdded:)])
                    
                    [[(__bridge DataService *)userData delegate] onWhiteboardObjectAdded:cbData];
                
                else if ([[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardObjectUpdated:)])
                    [[(__bridge DataService *)userData delegate] onWhiteboardObjectUpdated:cbData];
            }
            break;
        }
        case RtmpCallbackType_Whiteboard_ObjectRemove:
            DDLogDebug(@"RtmpCallbackType_Whiteboard_ObjectRemove: objId (%d)", *((int *)cbData));
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onWhiteboardObjectRemoved:)]) {
                
                [[(__bridge DataService *)userData delegate] onWhiteboardObjectRemoved:*((int *)cbData)];
            }
            break;
            
        case RtmpCallbackType_ExitApp:
            DDLogDebug(@"RtmpCallbackType_ExitApp");
            if ([(__bridge DataService *)userData delegate] &&
                [[(__bridge DataService *)userData delegate] respondsToSelector:@selector(onExitApp)]) {
                
                [[(__bridge DataService *)userData delegate] onExitApp];
            }
            break;
            
        default:
            DDLogDebug(@"Unknown callback type: %d", cbType);
            break;
    }
}

- (void)_executePostConnectedTasks {
    // Connect kWebinarUsersSo/kUsersSo shared object
    if ([self isLobbySession])
        [self connectSharedObject:kWebinarUsersSo flag:0];
    else
        [self connectSharedObject:kUsersSo flag:0];
    
    // Connect kVideoSo shared object for receving "turn on/off video" from tutor console
    [self connectSharedObject:kVideoSo flag:0];
    
    // Connect kChatSo shared object for receving "turn on/off chat" from tutor console
    [self connectSharedObject:kChatSo flag:0];
    
    // Connect whiteboard shared object
    [self invokeCmd:RtmpCmd_InvokeCmdFromString params:(void *)[[NSString stringWithFormat:@"wb.%@_%@.connect", self.userParams[@"sessionRoomId"], self.userParams[@"sessionSn"]] cStringUsingEncoding:NSUTF8StringEncoding]];
    [self connectSharedObject:[NSString stringWithFormat:@"wb.%@_%@.pages", self.userParams[@"sessionRoomId"], self.userParams[@"sessionSn"]] flag:2];
    
    // Get current anchor
    if ([self isGlassSession])
        [self invokeCmd:RtmpCmd_GetAnchor params:nil];
    
    // Get chat history
    [self invokeCmd:RtmpCmd_GetChatHistory params:nil];
}

#pragma markt - Chat handler
- (void)_sendMessageToGlass:(NSString *)message userName:(NSString *)userName {
    // Get UTC time
    NSTimeInterval millisecondedCurrentDate = ([[NSDate date] timeIntervalSince1970] * 1000);
    NSNumber *milliSecsUtc1970 = [NSNumber numberWithDouble:millisecondedCurrentDate];
    NSString *utcTime = [milliSecsUtc1970 stringValue];
    NSRange dotRange = [utcTime rangeOfString:@"."];
    if (dotRange.location != NSNotFound)
        utcTime = [utcTime substringToIndex:dotRange.location];
    
    // Compose query params
    NSArray *queryParams = @[[NSString stringWithFormat:@"SessionID=%@", self.userParams[@"sessionSn"]],
                             [NSString stringWithFormat:@"UserName=%@", [self getUserNameWithoutTilde]],
                             [NSString stringWithFormat:@"Message=%@", message],
                             [NSString stringWithFormat:@"Time=%@", utcTime]];
    
    // Send to chatroom server
    [HttpRequestUtility sendAsyncHttpRequest:[queryParams componentsJoinedByString:@"&"] urlStr:kGlassAddChatUrl];
}

- (void)sendMessage:(NSString *)message
           userName:(NSString *)userName
        senderLabel:(NSString *)senderLabel
           receiver:(NSString *)receiver
      receiverLabel:(NSString *)receiverLabel {
    
    // Send message to RTMP server
    SendMsg *sendMsg = malloc(sizeof(SendMsg));
    strncpy(sendMsg->msg, [message cStringUsingEncoding:NSUTF8StringEncoding], 1024);
    strncpy(sendMsg->username, [userName cStringUsingEncoding:NSUTF8StringEncoding], 50);
    strncpy(sendMsg->senderLabel, [senderLabel cStringUsingEncoding:NSUTF8StringEncoding], 50);
    strncpy(sendMsg->receiver, [receiver cStringUsingEncoding:NSUTF8StringEncoding], 50);
    strncpy(sendMsg->receiverLabel, [receiverLabel cStringUsingEncoding:NSUTF8StringEncoding], 50);
    
    [self invokeCmd:RtmpCmd_SendMessage params:(void *)sendMsg];
    
    free(sendMsg);
    
    // Send message to Chatroom server
    if ([self isGlassSession])
        [self _sendMessageToGlass:message userName:userName];
    
    // Log message
    [self.logService addChatLog:message];
}

- (void)clapHands:(NSString *)userName {
    [self invokeCmd:RtmpCmd_ClapHands params:(void *)[userName cStringUsingEncoding:NSUTF8StringEncoding]];
}

- (void)talkToConsultatnt:(NSString *)messageIndex
                 userName:(NSString *)userName {
    ConsultantMsg *consultantMsg = malloc(sizeof(ConsultantMsg));
    strncpy(consultantMsg->username, [userName cStringUsingEncoding:NSUTF8StringEncoding], 50);
    strncpy(consultantMsg->msgIndex, [messageIndex cStringUsingEncoding:NSUTF8StringEncoding], 5);
    
    [self invokeCmd:RtmpCmd_TalkToConsultant params:(void *)consultantMsg];
    
    free(consultantMsg);
}

#pragma mark - Whiteboard handler
- (void)switchWhiteboardPageTo:(int)toPageIdx from:(int)fromPageIdx {
    DDLogDebug(@"toPageIdx (%d), fromPageIdx (%d)", toPageIdx, fromPageIdx);
    if (fromPageIdx >= 0)
        [self disconnectSharedObject:[NSString stringWithFormat:@"wb.%@_%@.p%d", self.userParams[@"sessionRoomId"], self.userParams[@"sessionSn"], fromPageIdx] flag:2];
    
    if (toPageIdx >= 0)
        [self connectSharedObject:[NSString stringWithFormat:@"wb.%@_%@.p%d", self.userParams[@"sessionRoomId"], self.userParams[@"sessionSn"], toPageIdx] flag:2];
}

#pragma mark - Device handler
- (void)setSystemInfo:(NSString *)os userName:(NSString *)userName {
    SysInfo *sysInfo = malloc(sizeof(SysInfo));
    strncpy(sysInfo->username, [userName cStringUsingEncoding:NSUTF8StringEncoding], 50);
    strncpy(sysInfo->info, [[NSString stringWithFormat:@"%@||||||", os] cStringUsingEncoding:NSUTF8StringEncoding], 50);   // os | browser | javaInstallStr | airStr | relayStr | flashStr | countryCode
    
    [self invokeCmd:RtmpCmd_SetSysInfo params:(void *)sysInfo];
    
    free(sysInfo);
}

- (void)setSpeakerVolume:(int)vol {
    SpkrVol *spkrVol = malloc(sizeof(SpkrVol));
    memset(spkrVol, 0, sizeof(SpkrVol));
    
    strncpy(spkrVol->username, [self.userParams[@"userName"] cStringUsingEncoding:NSUTF8StringEncoding], 50);
    spkrVol->vol = vol;
    
    [self invokeCmd:RtmpCmd_SetSpeakerVol params:(void *)spkrVol];
    
    free(spkrVol);
    
    // Send kLogSpeakerVol to LogService
    [self.logService addSessionLog:kLogSpeakerVol content:[NSString stringWithFormat:@"%d", vol]];
}

- (void)setMicrophoneGain:(int)gain {
    MicGain *micGain = malloc(sizeof(MicGain));
    memset(micGain, 0, sizeof(MicGain));
    
    strncpy(micGain->username, [self.userParams[@"userName"] cStringUsingEncoding:NSUTF8StringEncoding], 50);
    micGain->gain = gain;
    micGain->type = [self isLobbySession] ? 2 : 1;
    
    [self invokeCmd:RtmpCmd_SetMicGain params:(void *)micGain];
    free(micGain);
    
    // Send kLogMicVol to LogService
    [self.logService addSessionLog:kLogMicVol content:[NSString stringWithFormat:@"%d", gain/10]];
}

- (void)setMicrophoneMute:(BOOL)mute {
    MicMute *micMute = malloc(sizeof(MicMute));
    memset(micMute, 0, sizeof(MicMute));
    
    strncpy(micMute->username, [self.userParams[@"userName"] cStringUsingEncoding:NSUTF8StringEncoding], 50);
    micMute->mute = mute;
    
    [self invokeCmd:RtmpCmd_SetMicMute params:(void *)micMute];
    
    free(micMute);
    
    // Send kLogMicMute to LogService
    [self.logService addSessionLog:kLogMicMute content:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:mute]]];
}
#pragma mark - Session Handler
- (void)sendLoginEvent:(NSString *)event {
    if (event)
        [self invokeCmd:RtmpCmd_SendLoginEvent params:(void *)[event cStringUsingEncoding:NSUTF8StringEncoding]];
}

- (void)sendLogoutEvent:(NSString *)event {
    if (event)
        [self invokeCmd:RtmpCmd_SendLogoutEvent params:(void *)[event cStringUsingEncoding:NSUTF8StringEncoding]];
}

- (void)sendLog:(NSDictionary *)logContents {
    // Send logContents to LogService
    if (logContents) {
        if (logContents[kLogLogin])
            [self.logService addSessionLog:kLogLogin content:logContents[kLogLogin]];
        if (logContents[kLogInputParams])
            [self.logService addSessionLog:kLogInputParams content:logContents[kLogInputParams]];
        if (logContents[kLogFmsRelay])
            [self.logService addSessionLog:kLogFmsRelay content:logContents[kLogFmsRelay]];
        if (logContents[kLogLogout])
            [self.logService addSessionLog:kLogLogout content:logContents[kLogLogout]];
    }
}

@end
