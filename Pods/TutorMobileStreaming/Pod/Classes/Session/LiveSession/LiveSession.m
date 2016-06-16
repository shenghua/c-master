//
//  LiveSession.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/25.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "LiveSession.h"
#import "TutorLog.h"
#import "UrlUtility.h"
#import "SessionConstants.h"
#import "WbObjectFactory.h"
#import "DeviceUtility.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#define kTutorConsoleHost   @"211.20.179.163"
#define kQATutorConsoleHost @"qa.tutormeet.com"

#define kCoordinator    @"coordinator"  // Default anchor
#define kCohost         @"cohost"       // Glass consultant
#define kStudent        @"student"
#define kSales          @"sales"

#define kDefaultEnableVPN      NO
#define kDefaultEnableRelay    YES

#define kDefaultUserVolumeFactor 0.5
#define kStartSessionTimeout 15

@interface LiveSession ()
@property (nonatomic, strong) NSDictionary *classInfo;
@property (nonatomic, strong) NSDictionary *connectParams;
@property (nonatomic, strong) NSString *relayServerIp;
@property (nonatomic, strong) NSString *sessionUrl;     // For data service
@property (nonatomic, strong) NSString *tutorConsoleUrl;
@property (nonatomic, strong) UIView *streamerView;
@property (nonatomic, strong) UIView *consultantView;
@property (nonatomic, strong) LiveWhiteboard *whiteboard;

@property (nonatomic, strong) NSTimer *startSessionTimer;
@property (nonatomic, strong) NSTimer *oneSecondTimer;
@property (nonatomic) dispatch_queue_t taskQueue;
@property (nonatomic) dispatch_queue_t concurrentTaskQueue;
@property (nonatomic, assign) BOOL sessionStopped;
@property (nonatomic, strong) DataService *dataService;
@property (nonatomic, strong) TutorConsoleService *tutorConsoleService;
@property (nonatomic, strong) Streamer *streamer;
@property (nonatomic, strong) NSMutableDictionary *players;     // Store all the players including coordinator, cohost and student
@property (nonatomic, strong) NSString *coordinatorUserName;    // Only support one coordinator
@property (nonatomic, strong) NSString *cohostUserName;         // Only support one cohost
@property (nonatomic, strong) NSMutableDictionary *playerPublishNameRoleDict;   // (userName, [publishName, role])

@property (nonatomic, strong) NSDictionary *musicDict;
@property (nonatomic, strong) AVPlayer     *musicPlayer;
@property (nonatomic, assign) SessionMusic currentMusic;

@property (nonatomic, strong) NSDateFormatter *curTimeFormatter;

@property (nonatomic, strong) NSMutableDictionary *msgIdDict;

@property (nonatomic, assign) int whiteboardTotalPages;
@property (nonatomic, assign) int whiteboardPageIdx;

@property (nonatomic, assign) CGFloat speakerVol;               // 0 ~ 1, default: 0.5
@property (nonatomic, assign) CameraPosition cameraPosition;
@end

@implementation LiveSession

- (instancetype)initSessionWithClassInfo:(NSDictionary *)classInfo
                                delegate:(id<LiveSessionDelegate>)delegate
                            streamerView:(UIView *)streamerView
                          consultantView:(UIView *)consultantView
                          whiteboardView:(UIView *)whiteboardView {
    self = [super init];
    if (self) {
        NSAssert(classInfo != nil, @"classInfo is nil !!");
        
        // Init Params
        _delegate = delegate;
        _streamerView = streamerView;
        _consultantView = consultantView;
        if (whiteboardView) {
            _whiteboard = [[LiveWhiteboard alloc] initWithFrame:CGRectMake(0, 0, whiteboardView.frame.size.width, whiteboardView.frame.size.height)
                                                       delegate:self];
            [_whiteboard setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [whiteboardView addSubview:_whiteboard];
        }
        
        _defaultUserVolumeFactor = kDefaultUserVolumeFactor;
        _enableVPN = kDefaultEnableVPN;
        _enableRelay = kDefaultEnableRelay;
        [self _parseClassInfo:classInfo];
        _shortUserName = [[self _getUserNameWithoutTilde:_connectParams[@"userName"]] copy];
        
        _playerPublishNameRoleDict = [NSMutableDictionary new];
        _taskQueue = dispatch_queue_create("LiveSession task queue", DISPATCH_QUEUE_SERIAL);
        _concurrentTaskQueue = dispatch_queue_create("LiveSession concurrent task queue", DISPATCH_QUEUE_CONCURRENT);
        _currentMusic = SessionMusic_None;
        _musicDict = @{@(SessionMusic_Start10Min)   : @"http://cn.tutormeet.com/tutormeet/assets/sessionStart10Min.mp3",
                       @(SessionMusic_Start3Min)    : @"http://cn.tutormeet.com/tutormeet/assets/sessionStart3Min.mp3",
                       @(SessionMusic_StartNow)     : @"http://cn.tutormeet.com/tutormeet/assets/sessionStartNow.mp3",
                       @(SessionMusic_End)          : @"http://cn.tutormeet.com/tutormeet/assets/sessionEnd.mp3",
                       @(SessionMusic_Clap)         : @"http://cn.tutormeet.com/tutormeet/assets/clap.mp3"};
        _curTimeFormatter = [[NSDateFormatter alloc] init];
        [_curTimeFormatter setDateFormat:@"HH:mm:ss"];
        _players = [NSMutableDictionary new];
        _msgIdDict = [NSMutableDictionary new];
        _cameraPosition = CameraPosition_Front;
    }
    return self;
}

- (void)startSession {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"startSession begin");
        
        // Create a startSessionTimer to avoid blocking in this function
        [self _createStartSessionTimer];
        
        // Init params
        _anchor = kCoordinator;
        _whiteboardTotalPages = 0;
        _whiteboardPageIdx = -1;
        _speakerVol = 0.5;
        
        // Enter classroom
        _sessionStopped = NO;
        
        // Create DataService
        _sessionStopped = ![self _startDataService];
        
        // Create Streamer
        if (!_sessionStopped) {
            if ([_connectParams[@"role"] isEqualToString:kCoordinator] || [_connectParams[@"role"] isEqualToString:kCohost])
                _sessionStopped = ![self _startStreamerWithAudio:YES withVideo:(_streamerView ? YES : NO)];
            else if ([_connectParams[@"role"] isEqualToString:kStudent] && [_connectParams[@"lobbySession"] caseInsensitiveCompare:@"false"] == NSOrderedSame)
                _sessionStopped = ![self _startStreamerWithAudio:YES withVideo:(_streamerView ? YES : NO)];
        }
        
        // Stop DataService and Streamer if startSession failed
        if (_sessionStopped) {
            [self _stopDataService];
            [self _stopStreamer];
        }

        if (_delegate && [_delegate respondsToSelector:@selector(onSessionStarted:)])
            [_delegate onSessionStarted:!_sessionStopped];
        
        // Release startSessionTimer
        [self _releaseStartSessionTimer];
        
        DDLogDebug(@"startSession end, succuss: %d", !_sessionStopped);
    });
}

- (void)stopSession {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"stopSession begin");
        
        // Stop session
        _sessionStopped = YES;
        
        // Release fps timer
        [self _releaseOneSecondTimer];
        
        // Release DataService
        [self _stopDataService];
        
        // Release TutorConsoleService
        [self _stopTutorConsoleService];
        
        // Stop Players
        [self _stopPlayers];
        
        // Stop session music player
        if (_musicPlayer)
            _musicPlayer = nil;
        
        // Release Streamer
        [self _stopStreamer];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onSessionStopped)])
            [_delegate onSessionStopped];
        
        DDLogDebug(@"stopSession end");
    });
}

#pragma mark - DataService Delegation
- (void)onConnected {
    DDLogDebug(@"onConnected");
    
    if (_dataService) {
        // Send log
        NSString *loginLog = [NSString stringWithFormat:@"%@->rtmp->%@ %@ ios %@", [self _getIPAddress], _classInfo[@"server"], [DeviceUtility platformName], [UIDevice currentDevice].systemVersion];
        NSString *inputParamsLog = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@",
                                    _connectParams[@"sessionSn"],
                                    _connectParams[@"sessionRoomId"],
                                    _connectParams[@"role"],
                                    _connectParams[@"userSn"],
                                    _connectParams[@"userType"],
                                    _connectParams[@"lobbySession"],
                                    _connectParams[@"glassSession"],
                                    _connectParams[@"closeType"],
                                    _connectParams[@"compStatus"]];
        NSDictionary *logContents = @{kLogLogin: loginLog,
                                      kLogInputParams: inputParamsLog};
        [_dataService sendLog:logContents];
        
        if (_relayServerIp) {
            NSString *ip = _classInfo[@"server"];
            if (_enableVPN && [@"1" isEqualToString:_classInfo[@"vpn"]])
                ip = _classInfo[@"internalServer"];
            
            NSString *relayLog = [NSString stringWithFormat:@"rtmp://%@/?rtmp://%@/tutormeet/%@_%@", _relayServerIp, ip, _classInfo[@"sessionRoomId"], _classInfo[@"sessionSn"]];
            [_dataService sendLog:@{kLogFmsRelay: relayLog}];
        }
        
        // Send login event if not lobby session
        if ([_connectParams[@"lobbySession"] caseInsensitiveCompare:@"false"] == NSOrderedSame) {
            if ([_connectParams[@"role"] isEqualToString:@"student"])
                [_dataService sendLoginEvent:[NSString stringWithFormat:@"%@-%@|%d|%@", kRecordedSessionEvent_Record, _connectParams[@"userName"], 0, _connectParams[@"roomType"]]];
            else if ([_connectParams[@"role"] isEqualToString:kCoordinator] || [_connectParams[@"role"] isEqualToString:kCohost])
                [_dataService sendLoginEvent:[NSString stringWithFormat:@"%@-%@|%d|%@", kRecordedSessionEvent_Record, _connectParams[@"userName"], 1, _connectParams[@"roomType"]]];
        }
        
        // Set system info
        [_dataService setSystemInfo:kOsIos userName:_connectParams[@"userName"]];
        
        // Set speaker volume
        if (_dataService)
            [_dataService setSpeakerVolume:_speakerVol * 10];
        
        // Set microphone gain
        [_dataService setMicrophoneGain:_streamer.microphoneGain * 100];
    }
    
    // Set microphone mute if lobby session
    if ([_connectParams[@"lobbySession"] caseInsensitiveCompare:@"true"] == NSOrderedSame)
        [self setMicrophoneMute:YES];
}

- (void)onAnchorChanged:(NSString *)anchor {
    DDLogDebug(@"onAnchorChanged anchor: %@", anchor);
    
    if (!anchor || [_anchor isEqualToString:anchor])
        return;
    
    @synchronized(_players) {
        NSString *userName = nil;
        
        // Mute the current anchor
        if ([_anchor isEqualToString:kCoordinator])
            userName = _coordinatorUserName;
        else if ([_anchor isEqualToString:kCohost])
            userName = _cohostUserName;
        
        if (userName && [_players objectForKey:userName]) {
            Player *player = [_players objectForKey:userName];
            [player setMute:YES];
        }
        
        // Set video view and unmute the new anchor
        if ([anchor isEqualToString:kCoordinator])
            userName = _coordinatorUserName;
        else if ([anchor isEqualToString:kCohost])
            userName = _cohostUserName;
        
        if (userName && [_players objectForKey:userName]) {
            Player *player = [_players objectForKey:userName];
            [player setMute:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[_consultantView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                
                UIView *videoView = [player videoView];
                videoView.frame = _consultantView.bounds;
                
                [_consultantView insertSubview:videoView atIndex:0];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[_consultantView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            });
        }
    }
    
    _anchor = anchor;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onAnchorChanged:)])
        [_delegate onAnchorChanged:anchor];
}

- (void)onUserIn:(NSString *)userName publishName:(NSString *)publishName role:(NSString *)role isLobbySession:(BOOL)isLobbySession {
    DDLogDebug(@"onUserIn userName: %@, publishName: %@, role: %@, isLobbySession: %d", userName, publishName, role, isLobbySession);

    // Null pointer checking
    if (!userName || !publishName || !role)
        return;
    
    // Return if user is self
    if (_connectParams[@"userName"] && [_connectParams[@"userName"] isEqualToString:userName])
        return;
    
    // Create player according to role and isLobbySession
    dispatch_async(_concurrentTaskQueue, ^{
        
        Player *player;
        @synchronized(_players) {
            // Check if player has already existed
            if ([_players objectForKey:userName]) {
                DDLogDebug(@"onUserIn user (%@) already existed, return directly", userName);
                return;
            }
            else {
                NSString *playerUrl = [self _createPlayerUrlWithPublishName:publishName];
                
                if ([role isEqualToString:kCoordinator] || [role isEqualToString:kCohost])
                    player = [self _createPlayer:playerUrl userName:userName publishName:publishName role:role withAudio:YES withVideo:YES];
                else if (([role isEqualToString:kStudent] || [role isEqualToString:kSales]) && !isLobbySession)
                    player = [self _createPlayer:playerUrl userName:userName publishName:publishName role:role withAudio:YES withVideo:NO];
                
                if (player)
                    _players[userName] = player;
            }
        }
        
        if (player) {
            if (_delegate && [_delegate respondsToSelector:@selector(onUserIn:role:)])
                [_delegate onUserIn:userName role:role];
            
            if ([self _startPlayer:player]) { // this is a blocking function!!
                [player setVolumeFactor:_defaultUserVolumeFactor];
                
                if ([role isEqualToString:kCoordinator] || [role isEqualToString:kCohost]) {
                    // Set video view if the current anhor is the newly created player
                    if (([role isEqualToString:kCoordinator] && [_anchor isEqualToString:kCoordinator]) ||
                        ([role isEqualToString:kCohost] && [_anchor isEqualToString:kCohost])) {
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [[_consultantView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                            
                            UIView *videoView = [player videoView];
                            videoView.frame = _consultantView.bounds;
                            
                            [_consultantView insertSubview:videoView atIndex:0];
                        });
                    } else {
                        // Mute player since it is not the current anchor
                        [player setMute:YES];
                    }
                    
                    if ([role isEqualToString:kCoordinator])
                        _coordinatorUserName = [userName copy];
                    else
                        _cohostUserName = [userName copy];
                    // Create one second timer
                    [self _createOneSecondTimer];
                }
            }
            else
                [self reconnectUser:userName];
        }
    });
}

- (void)onUserOut:(NSString *)userName {
    DDLogDebug(@"onUserOut userName: %@", userName);
    
    if (!userName)
        return;
    
    dispatch_async(_taskQueue, ^{
        @synchronized(_players) {
            if ([_players objectForKey:userName]) {
                Player *player = [_players objectForKey:userName];
                
                if ([player.role isEqualToString:kCoordinator])
                    _coordinatorUserName = nil;
                else if ([player.role isEqualToString:kCohost])
                    _cohostUserName = nil;
                
                [self _stopPlayer:player];
                [_players removeObjectForKey:userName];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(onUserOut:)])
                [_delegate onUserOut:userName];
        }
    });
}

- (void)onMessage:(NSArray *)messageArray {
    DDLogDebug(@"onMessage messageArray: %@", messageArray);

    if (_delegate && [_delegate respondsToSelector:@selector(onMessage:)]) {
        NSMutableArray *chatMessageArray = [NSMutableArray new];
        
        for (NSDictionary *message in messageArray) {
            SessionChatMessagePriority priority = SessionChatMessagePriority_Normal;
            
            if ([message[@"receiver"] isEqualToString:_connectParams[@"userName"]])
                priority = SessionChatMessagePriority_High;
            else if ([message[@"receiver"] isEqualToString:@"All"])
                priority = SessionChatMessagePriority_Normal;
            else    // Do not display the message not sending to me
                return;
            
            NSString *userName = [message[@"userTime"] substringToIndex:[message[@"userTime"] length] - 9]; // Sendoh Chen 00:00:00 => Sendoh Chen
            NSString *time = [_curTimeFormatter stringFromDate:[NSDate date]];
            
            SessionChatMessage *msg = [[SessionChatMessage alloc] initWithUserName:userName time:time message:message[@"message"] priority:priority];
            [chatMessageArray addObject:msg];
        }
        
        [_delegate onMessage:chatMessageArray];
    }
}

- (void)onPlayMusic:(SessionMusic)music {
    DDLogDebug(@"onPlayMusic music: %d", music);
    
    if (music != _currentMusic) {
        _currentMusic = music;
        
        // Stop the current music player
        if (_musicPlayer) {
            [_musicPlayer pause];
            _musicPlayer = nil;
        }
        
        // Play new music
        AVPlayerItem *musicPlayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:_musicDict[@(_currentMusic)]]];
        _musicPlayer = [[AVPlayer alloc] initWithPlayerItem:musicPlayerItem];
        [_musicPlayer play];
    }
}

- (void)onClapHands:(NSString *)userName {
    DDLogDebug(@"onClapHands userName: %@", userName);
    
    AVPlayerItem *clapPlayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:_musicDict[@(SessionMusic_Clap)]]];
    if (clapPlayerItem) {
        AVPlayer *clapPlayer = [[AVPlayer alloc] initWithPlayerItem:clapPlayerItem];
        if (clapPlayer)
            [clapPlayer play];
    }
}

- (void)onConsultantLost:(NSString *)consultant {
    DDLogDebug(@"onConsultantLost consultant: %@", consultant);
    
    if (_delegate && [_delegate respondsToSelector:@selector(onConsultantLost:)])
        [_delegate onConsultantLost:consultant];
}

- (void)onSendWaitMsg {
    DDLogDebug(@"onSendWaitMsg");
    
    if (_delegate && [_delegate respondsToSelector:@selector(onSendWaitMsg)])
        [_delegate onSendWaitMsg];
}

- (void)onMicMute:(BOOL)mute {
    DDLogDebug(@"onMute mute: %d", mute);
    
    if (_delegate && [_delegate respondsToSelector:@selector(onMicMute:)])
        [_delegate onMicMute:mute];
}

- (void)onSpkrVolChanged:(int)vol {
    DDLogDebug(@"onSpkrVolChanged: %f", vol/10.0);
    
    _speakerVol = vol/10.0;
    
    // Adjust players' speaker volume
    @synchronized(_players) {
        for (Player *player in [_players allValues]) {
            player.spkrVolFactor = _speakerVol * 2;
        }
    }
    
    if (_dataService)
        [_dataService setSpeakerVolume:vol];
}

- (void)onMicGainChanged:(int)gain {
    DDLogDebug(@"onMicGainChanged: %f", gain/100.0);
    
    if (_delegate && [_delegate respondsToSelector:@selector(onMicGainChanged:)])
        [_delegate onMicGainChanged:gain/100.0];
}

- (void)onHelpMessage:(NSString *)messageId msgIdx:(int)msgIdx status:(HelpMsgStatus)status {
    DDLogDebug(@"onHelpMessage: messageId (%@), msgIdx (%d), status (%d)", messageId, msgIdx, status);
    NSNumber *messageIndex = @(msgIdx);
    
    // Store msgId/messageIndex when HelpMsgStatus_Waiting
    if (status == HelpMsgStatus_Waiting) {
        if (!_msgIdDict[messageId])
            [_msgIdDict setObject:messageIndex forKey:messageId];
    }
    // Retrieve messageIndex when HelpMsgStatus_Processing or HelpMsgStatus_Done
    else if (status == HelpMsgStatus_Processing || status == HelpMsgStatus_Done) {
        if (_msgIdDict[messageId])
            messageIndex = _msgIdDict[messageId];
        else
            return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onHelpMessage:status:)])
        [_delegate onHelpMessage:messageIndex status:status];
}

- (void)onDisableVideo:(int)disable userName:(NSString *)userName {
    if (userName && [userName isEqualToString:_connectParams[@"userName"]] &&
        _delegate && [_delegate respondsToSelector:@selector(onDisableVideo:)])
        [_delegate onDisableVideo:disable];
}

- (void)onDisableChat:(int)disable userName:(NSString *)userName {
    if (userName && [userName isEqualToString:_connectParams[@"userName"]] &&
        _delegate && [_delegate respondsToSelector:@selector(onDisableChat:)])
        [_delegate onDisableChat:disable];
}

- (void)onRelogin {
    if (_delegate && [_delegate respondsToSelector:@selector(onRelogin)])
        [_delegate onRelogin];
}

- (void)onAdminMessage:(NSString *)msg {
    DDLogDebug(@"onAdminMessage: %@", msg);
    
    NSArray *msgArr = [msg componentsSeparatedByString:@"|"];
    BOOL callbackOnAdminMessage = NO;
    
    if (msgArr && [msgArr count] > 1) {
        NSString *actionType = msgArr[0];
        if ([actionType isEqualToString:@"1"]) {        // broadcast message
            msg = msgArr[1];
            callbackOnAdminMessage = YES;
        }
        else if ([actionType isEqualToString:@"2"]) {   // reconnect server
            NSString *newServerIP = msgArr[1];
            NSString *newRelayIP = msgArr[2];
            
            if (_delegate && [_delegate respondsToSelector:@selector(onAdminMessageReconnectServer:newRelayIp:)]) {
                [_delegate onAdminMessageReconnectServer:newServerIP newRelayIp:newRelayIP];
                return;
            }
        }
        else if ([actionType isEqualToString:@"3"]) {   // broadcast to single user
            NSString *userName = msgArr[1];
            msg = msgArr[2];
            
            if ([userName isEqualToString:_connectParams[@"userName"]])
                callbackOnAdminMessage = YES;
        }
    }
    else                                                // broadcast message
        callbackOnAdminMessage = YES;
    
    if (callbackOnAdminMessage && _delegate && [_delegate respondsToSelector:@selector(onAdminMessage:)])
        [_delegate onAdminMessage:msg];
}

- (void)onExitApp {
    if (_delegate && [_delegate respondsToSelector:@selector(onExitApp)])
        [_delegate onExitApp];
}

- (void)onWhiteboardPageChanged:(int)pageIdx {
    [self switchWhiteboardPage:pageIdx];
}

- (void)onWhiteboardTotalPages:(int)totalPages {
    _whiteboardTotalPages = totalPages;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardTotalPages:)])
        [_delegate onWhiteboardTotalPages:totalPages];
}

- (void)onWhiteboardResetWebPointer {
    if (_whiteboard)
        [_whiteboard resetWebPointer];
    
    else if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardResetWebPointer)])
        [_delegate onWhiteboardResetWebPointer];
}

- (void)onWhiteboardResetWebMouse {
    if (_whiteboard)
        [_whiteboard resetWebMouse];
    
    else if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardResetWebMouse)])
        [_delegate onWhiteboardResetWebMouse];
}

- (void)onWhiteboardWebPointerChange:(CGPoint)point {
    if (_whiteboard)
        [_whiteboard webPointerChange:point];
    
    else if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardWebPointerChange:)])
        [_delegate onWhiteboardWebPointerChange:point];
}

- (void)onWhiteboardWebMouseChange:(CGPoint)point {
    if (_whiteboard)
        [_whiteboard webMouseChange:point];
    
    else if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardWebMouseChange:)])
        [_delegate onWhiteboardWebMouseChange:point];
}

- (void)onWhiteboardObjectAdded:(WhiteboardObject *)wbObject {
    // Workaround server sends wrong material issue
    if (wbObject->shape == WhiteboardShape_Image) {
        SessionWhiteboardObject *sessionWbObj = [WbObjectFactory getRecordedWbObjectFromLiveWbObject:wbObject];
        if (sessionWbObj && sessionWbObj.properties[@(5)] && [sessionWbObj.properties[@(5)] rangeOfString:_connectParams[@"sessionSn"]].location == NSNotFound &&
            ([_connectParams[@"roomType"] intValue] == SessionRoomType_Normal || [_connectParams[@"roomType"] intValue] == SessionRoomType_Webcast1)) {
            
            return;
        }
    }
    
    // Clear current page if necessary
    if (_whiteboard && wbObject->objId == 0) {
        [_whiteboard clearAllObjects];
    }
    
    if (_whiteboard)
        [_whiteboard addObject:wbObject];
    
    else if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardObjectAdded:)])
        [_delegate onWhiteboardObjectAdded:wbObject];
}

- (void)onWhiteboardObjectUpdated:(WhiteboardObject *)wbObject {
    if (_whiteboard)
        [_whiteboard updateObject:wbObject];
    
    else if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardObjectUpdated:)])
        [_delegate onWhiteboardObjectUpdated:wbObject];
}

- (void)onWhiteboardObjectRemoved:(int)objId {
    if (_whiteboard)
        [_whiteboard removeObject:objId];
    
    else if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardObjectRemoved:)])
        [_delegate onWhiteboardObjectRemoved:objId];
}

#pragma mark - Whiteboard Delegation
- (void)onWhiteboardSwipeLeft {
    if (_whiteboardPageIdx < _whiteboardTotalPages - 1) {
        [self switchWhiteboardPage:_whiteboardPageIdx + 1];
    }
}

- (void)onWhiteboardSwipeRight {
    if (_whiteboardPageIdx > 0) {
        [self switchWhiteboardPage:_whiteboardPageIdx - 1];
    }
}

#pragma mark - DataService Controller

- (BOOL)_startDataService {
    DDLogDebug(@"_startDataService begin");
    if (!_dataService)
        _dataService = [[DataService alloc] initWithUrl:_sessionUrl delegate:self userParams:_connectParams];
    
    [NSThread sleepForTimeInterval:1];  // Workaround _dataService connect failed issue
    BOOL connected = [_dataService connect];

    DDLogDebug(@"_startDataService end");
    return connected;
}

- (void)_stopDataService {
    if (_dataService) {
        DDLogDebug(@"_stopDataService begin");
        // Send log
        NSDictionary *logContents = @{kLogLogout:@"logout"};
        [_dataService sendLog:logContents];
        
        // Send logout event if not lobby session
        if ([_connectParams[@"lobbySession"] caseInsensitiveCompare:@"false"] == NSOrderedSame) {
            if ([_connectParams[@"role"] isEqualToString:@"student"])
                [_dataService sendLogoutEvent:[NSString stringWithFormat:@"%@-%@|%d", kRecordedSessionEvent_Logout, _connectParams[@"userName"], 0]];
            else if ([_connectParams[@"role"] isEqualToString:kCoordinator] || [_connectParams[@"role"] isEqualToString:kCohost])
                [_dataService sendLogoutEvent:[NSString stringWithFormat:@"%@-%@|%d", kRecordedSessionEvent_Logout, _connectParams[@"userName"], 1]];
        }
        
        // Disconnect data service
        [_dataService disconnect];
        
        _dataService = nil;
        DDLogDebug(@"_stopDataService end");
    }
}

#pragma mark - TutorConsoleService Controller

- (void)_startTutorConsoleService {
    _tutorConsoleService = [[TutorConsoleService alloc] initWithUrl:_tutorConsoleUrl delegate:self userParams:_connectParams];
    
    if (_tutorConsoleService) {
        DDLogDebug(@"_startTutorConsoleService begin");
        [_tutorConsoleService connect];
        DDLogDebug(@"_startTutorConsoleService end");
    }
}

- (void)_stopTutorConsoleService {
    if (_tutorConsoleService) {
        DDLogDebug(@"_stopTutorConsoleService begin");
        [_tutorConsoleService disconnect];
        _tutorConsoleService = nil;
        DDLogDebug(@"_stopTutorConsoleService end");
    }
}

#pragma mark - Streamer Controller
- (BOOL)_startStreamerWithAudio:(BOOL)withAudio withVideo:(BOOL)withVideo {
    DDLogDebug(@"_startStreamer: (A: %d, V: %d) begin", withAudio, withVideo);
    
    // Initialize streamer
    if (!_streamer) {
        _streamer = [[Streamer alloc] initWithUrl:_sessionUrl withAudio:withAudio withVideo:withVideo relayServerIp:_relayServerIp];
        _streamer.delegate = self;
        _streamer.cameraPosition = _cameraPosition;
        
        if (_dataService) {
            [_dataService setMicrophoneGain:_streamer.microphoneGain * 100];
            [_dataService setMicrophoneMute:_streamer.microphoneMute];
        }
    }
    
    if (!_streamer.isStreaming)
        [_streamer startStreaming];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVCaptureVideoPreviewLayer *preview = _streamer.previewLayer;
        [preview removeFromSuperlayer];
        preview.frame = _streamerView.bounds;
        
        [_streamerView.layer addSublayer:preview];
    });
    
    DDLogDebug(@"_startStreamer: (A: %d, V: %d) end, success (%d)", withAudio, withVideo, _streamer.isStreaming);
    return _streamer.isStreaming;
}

- (void)_stopStreamer {
    if (_streamer) {
        DDLogDebug(@"_stopStreamer begin");
        [_streamer stopStreaming];
        _streamer = nil;
        
        if (_streamerView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (CALayer *layer in _streamerView.layer.sublayers)
                    [layer removeFromSuperlayer];
            });
        }
        
        DDLogDebug(@"_stopStreamer end");
    }
}

#pragma mark - Player Controller
- (NSString *)_createPlayerUrlWithPublishName:(NSString *)publishName {
    if (!publishName)
        return nil;
    
    NSString *playerUrl = nil;
    NSString *playPath = [_sessionUrl lastPathComponent];
    NSRange rangePlayPath = [_sessionUrl rangeOfString:playPath];
    NSRange rangeQuestionMark = [_sessionUrl rangeOfString:@"?"];
    
    if (rangeQuestionMark.location != NSNotFound) {
        playerUrl = [NSString stringWithFormat:@"%@%@%@", [_sessionUrl substringToIndex:rangePlayPath.location],
                     publishName,
                     [_sessionUrl substringFromIndex:rangeQuestionMark.location]];
    } else {
        playerUrl = [NSString stringWithFormat:@"%@%@", [_sessionUrl substringToIndex:rangePlayPath.location],
                     publishName];
    }
    
    return playerUrl;
}

- (Player *)_createPlayer:(NSString *)url
                 userName:(NSString *)userName
              publishName:(NSString *)publishName
                     role:(NSString *)role
                withAudio:(BOOL)withAudio
                withVideo:(BOOL)withVideo {
    DDLogDebug(@"_createPlayer: %@ begin", userName);
    
    _playerPublishNameRoleDict[userName] = @[publishName, role];
    
    Player *player = [[Player alloc] initWithUrl:url
                                        delegate:self
                                       withAudio:withAudio
                                       withVideo:withVideo
                                        liveMode:YES
                                        userName:userName
                                            role:role
                                   relayServerIp:_relayServerIp];
    
    DDLogDebug(@"_createPlayer: %@ end", userName);
    return player;
}

- (BOOL)_startPlayer:(Player *)player {
    DDLogDebug(@"_startPlayer: %@ begin", player.userName);
    
    if (player) {
        BOOL success = [player startPlaying];
        
        DDLogDebug(@"_startPlayer: %@ end, success (%d)", player.userName, success);
        return success;
    }
    
    DDLogDebug(@"_startPlayer: %@ end, success (%d)", player.userName, 0);
    return NO;
}

- (void)_stopPlayer:(Player *)player {
    if (player) {
        DDLogDebug(@"_stopPlayer: %@ begin", player.userName);
        [player stopPlaying];
        player = nil;
        DDLogDebug(@"_stopPlayer end");
    }
}

- (void)_stopPlayers {
    DDLogDebug(@"_stopPlayers begin");
    
    // In order to wait for _startPlayer finished, we use @synchronized here.
    @synchronized(_players){
        for (Player *player in [_players allValues]) {
            [self _stopPlayer:player];
        }
        [_players removeAllObjects];
    }
    
    DDLogDebug(@"_stopPlayers end");
}

#pragma mark - PlayerDelegate Handler
- (void)onNoFrameGot:(NSString *)userName {
    DDLogDebug(@"onNoFrameGot: %@", userName);
    if (!_sessionStopped && _delegate && [_delegate respondsToSelector:@selector(onNoFrameGot:)])
        [_delegate onNoFrameGot:userName];
}

- (void)onGetFrameFailed:(NSString *)userName {
    DDLogDebug(@"onGetFrameFailed: %@", userName);
    [self onUserOut:userName];
}

- (void)onInsufficientBW:(NSString *)userName {
    DDLogDebug(@"onInsufficientBW: %@", userName);
}

#pragma mark - Public methods (User)
- (void)reconnectUser:(NSString *)userName {
    if (_sessionStopped)
        return;
    
    DDLogDebug(@"reconnectUser: %@", userName);
    
    [self disconnectUser:userName];
    
    [NSThread sleepForTimeInterval:1];  // Workaround onUserIn logic is executed before onUserOut
    
    [self connectUser:userName];
}

- (void)connectUser:(NSString *)userName {
    DDLogDebug(@"connectUser: %@", userName);
    
    NSString *publishName = _playerPublishNameRoleDict[userName][0];
    NSString *role = _playerPublishNameRoleDict[userName][1];
    BOOL isLobbySession = [_connectParams[@"lobbySession"] caseInsensitiveCompare:@"true"] == NSOrderedSame;
    
    [self onUserIn:userName publishName:publishName role:role isLobbySession:isLobbySession];
}

- (void)disconnectUser:(NSString *)userName {
    DDLogDebug(@"disconnectUser: %@", userName);
    
    [self onUserOut:userName];
}

#pragma mark - Public methods (Chat)
- (void)sendMessageToAll:(NSString *)message {
    if (_dataService)
        [_dataService sendMessage:message userName:_connectParams[@"userName"] senderLabel:@"" receiver:@"All" receiverLabel:@""];
}

- (void)sendMessageToConsultatnt:(NSString *)message msgIndex:(int)index {
    if (_dataService) {
        NSString *receiver;
        if ([_anchor isEqualToString:kCohost])
            receiver = _cohostUserName;
        else if ([_anchor isEqualToString:kCoordinator])
            receiver = _coordinatorUserName;
            
        if (receiver) {
            [_dataService talkToConsultatnt:[NSString stringWithFormat:@"%d", index] userName:receiver];
            [_dataService sendMessage:message userName:_connectParams[@"userName"] senderLabel:@"" receiver:receiver receiverLabel:@""];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onMessage:)]) {
            NSString *userName = [NSString stringWithFormat:@"%@ to %@", _shortUserName, [self _getUserNameWithoutTilde:receiver]];
            NSString *time = [_curTimeFormatter stringFromDate:[NSDate date]];
            
            SessionChatMessage *mesg = [[SessionChatMessage alloc] initWithUserName:userName time:time message:message priority:SessionChatMessagePriority_High];
            [_delegate onMessage:@[mesg]];
        }
    }
}

- (void)sendMessageToIT:(NSString *)message {
    if (_dataService) {
        NSString *receiver = @"IT";
        [_dataService sendMessage:message userName:_connectParams[@"userName"] senderLabel:@"" receiver:receiver receiverLabel:@""];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onMessage:)]) {
            NSString *userName = [NSString stringWithFormat:@"%@ to %@", _shortUserName, receiver];
            NSString *time = [_curTimeFormatter stringFromDate:[NSDate date]];
            
            SessionChatMessage *mesg = [[SessionChatMessage alloc] initWithUserName:userName time:time message:message priority:SessionChatMessagePriority_High];
            [_delegate onMessage:@[mesg]];
        }
    }
}

- (void)sendHelpMessage:(NSString *)message msgIdx:(NSNumber *)msgIdx {
    dispatch_async(_taskQueue, ^{
        // Create TutorConsoleService
        if (!_tutorConsoleService)
            [self _startTutorConsoleService];
        
        if (_tutorConsoleService)
            [_tutorConsoleService sendHelpMessage:message custSupMsgIndex:[msgIdx intValue] custSupType:HelpMsgType_Clicked];
    });
}

- (void)confirmHelpMsg:(NSNumber *)msgIdx confirmed:(HelpMsgConfirmed)confirmed {
    if (_tutorConsoleService) {
        
        // Find msgId from _msgIdDict
        __block NSString *msgId;
        [_msgIdDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            if ([object isEqualToNumber:msgIdx]) {
                msgId = [(NSString *)key copy];
                *stop = YES;
            }
        }];
        
        if (msgId) {
            [_tutorConsoleService confirmHelpMsg:msgId confirmed:confirmed];
            
            // Remove the confirmed help msg
            [_msgIdDict removeObjectForKey:msgId];
        }
    }
}

- (void)clapHands {
    // Send clap hands message
    [self sendMessageToAll:NSLocalizedString(@"Clap Hands", @"str -- Clap Hands")];
    
    // Play clap hands music
    [self onPlayMusic:SessionMusic_Clap];
    
    // Send clap hands command
    if (_dataService)
        [_dataService clapHands:_connectParams[@"userName"]];
}

#pragma mark - Public methods (Microphone)
- (void)setMicrophoneGain:(float)gain {
    if (_streamer)
        _streamer.microphoneGain = gain;
    
    if (_dataService)
        [_dataService setMicrophoneGain:gain * 100];
}

- (float)getMicrophoneGain {
    if (_streamer)
        return _streamer.microphoneGain;
    else
        return 0;
}

- (BOOL)getMicrophoneMute {
    return _streamer? _streamer.microphoneMute: NO;
}

- (void)setMicrophoneMute:(BOOL)mute {
    if (_streamer)
        _streamer.microphoneMute = mute;
    
    if (_dataService)
        [_dataService setMicrophoneMute:mute];
}

#pragma mark - Public methods (Volume)

- (void)setUserVolumeFactor:(float)volumeFactor userName:(NSString *)userName {
    if (!_players)
        return;
    
    @synchronized(_players){
        if ([_players objectForKey:userName]) {
            Player *player = [_players objectForKey:userName];
            player.volumeFactor = volumeFactor;
        }
    };
}

- (float)getUserVolumeFactor:(NSString *)userName {
    float volumeFactor = 1.0;
    
    if (!_players)
        return volumeFactor;
    
    @synchronized(_players){
        if ([_players objectForKey:userName]) {
            Player *player = [_players objectForKey:userName];
            volumeFactor = player.volumeFactor;
        }
    };
    
    return volumeFactor;
}

#pragma mark - Public methods (Whiteboard)
- (void)switchWhiteboardPage:(int)pageIdx {
    if (pageIdx != _whiteboardPageIdx) {
        dispatch_async(_taskQueue, ^{
            // Clear current page
            if (_whiteboard)
                [_whiteboard clearAllObjects];
            
            // Switch to the next page
            if (_dataService)
                [_dataService switchWhiteboardPageTo:pageIdx from:_whiteboardPageIdx];
            
            // Callback upper layer
            if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardPageChanged:)])
                [_delegate onWhiteboardPageChanged:pageIdx];
            
            _whiteboardPageIdx = pageIdx;
        });
    }
}

#pragma mark - Public methods (Streamer)
- (void)setCameraPosition:(CameraPosition)position {
    _cameraPosition = position;
    
    if (_streamer)
        _streamer.cameraPosition = _cameraPosition;
}

- (CameraPosition)getCameraPosition {
    return _cameraPosition;
}

#pragma mark - Utilities

- (NSString *)_getUserNameWithoutTilde:(NSString *)userName {
    NSRange range = [userName rangeOfString:@"~"];
    if (range.location != NSNotFound)
        userName = [userName substringToIndex:range.location];

    return userName;
}

- (NSString *)_getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

#pragma mark - Timer
- (void)_createStartSessionTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _releaseStartSessionTimer];
        _startSessionTimer = [NSTimer scheduledTimerWithTimeInterval:kStartSessionTimeout target:self selector:@selector(_startSessionTimerCallback:) userInfo:nil repeats:NO];
    });
}

- (void)_releaseStartSessionTimer {
    if (_startSessionTimer) {
        [_startSessionTimer invalidate];
        _startSessionTimer = nil;
    }
}

- (void)_startSessionTimerCallback:(NSTimer *)timer {
    [self _releaseStartSessionTimer];
    
    DDLogDebug(@"startSessin timeout!!");
    
    [self stopSession];
    
    if (_delegate && [_delegate respondsToSelector:@selector(onSessionStarted:)])
        [_delegate onSessionStarted:NO];
}

- (void)_createOneSecondTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _releaseOneSecondTimer];
        _oneSecondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_oneSecondTimerCallback:) userInfo:nil repeats:YES];
    });
}

- (void)_releaseOneSecondTimer {
    if (_oneSecondTimer) {
        [_oneSecondTimer invalidate];
        _oneSecondTimer = nil;
    }
}

- (void)_oneSecondTimerCallback:(NSTimer *)timer {
    dispatch_async(_taskQueue, ^{
        NSString *userName = [_anchor isEqualToString:kCoordinator] ? _coordinatorUserName : _cohostUserName;
        
        if (!_players || !userName)
            return;
        
        int fps = 0;
        float position = 0;
        
        @synchronized(_players){
            if ([_players objectForKey:userName]) {
                Player *player = [_players objectForKey:userName];
                fps = player.videoFps;
                position = player.currentPos;
            }
        };
        
        DDLogDebug(@"Video FPS: %d, player position: %f", fps, position);
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoFps:)])
            [_delegate onVideoFps:fps];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onPositionChanged:)])
            [_delegate onPositionChanged:position * 1000];
    });
}

#pragma mark - Class Info Parser
- (void)_parseClassInfo:(NSDictionary *)classInfo {
    _classInfo = [classInfo copy];
    
    [self _parseConnectParams];
    [self _parseSessionUrl];
    [self _parseRelayServerIp];
    [self _parseTutorConsoleUrl];
}

- (NSDictionary *)_parseConnectParams {
    _connectParams = @{@"userName": [NSString stringWithFormat:@"%@~%@", _classInfo[@"ename"], _classInfo[@"clientSn"]],
                       @"role": [@"user" isEqualToString:_classInfo[@"role"]]? @"student": _classInfo[@"role"],
                       @"sessionSn": _classInfo[@"sessionSn"],
                       @"userSn": _classInfo[@"clientSn"],
                       @"userType": @"1",
                       @"firstName": _classInfo[@"firstName"],
                       @"roomType": _classInfo[@"roomType"],
                       @"compStatus": _classInfo[@"compStatus"],
                       @"sessionRoomId": _classInfo[@"sessionRoomId"],
                       @"lobbySession": [_classInfo[@"lobbySession"] isEqualToString:@"N"]? @"false": @"true",
                       @"glassSession": ([_classInfo[@"roomType"] intValue] == SessionRoomType_TutorGlassWebcast || [_classInfo[@"roomType"] intValue] == SessionRoomType_TutorGlass) ? @"true" : @"false",
                       @"rating": _classInfo[@"rating"],
                       @"recordStatus": @"1",
                       @"cname": _classInfo[@"cname"],
                       @"password": @"",
                       @"liveDelay": @"false",
                       @"camera": (([_classInfo[@"lobbySession"] isEqualToString:@"N"] && _streamerView) ? @"true" : @"false"),   // ture if not lobbySession and streamerView provided
                       @"closeType": _classInfo[@"closeType"],
                       @"auth": @"0",
                       @"streamFileFormatPrefix": @"",
                       @"email": @"",
                       @"protocol": @"rtmp",
                       @"commProcMode": @"1",
                       @"streamFileFormat": @"",
                       @"clockStartMin": @"30"};
    return _connectParams;
}

- (NSString *)_parseSessionUrl {
    NSString *ip = _classInfo[@"server"];
    if (_enableVPN && [@"1" isEqualToString:_classInfo[@"vpn"]])
        ip = _classInfo[@"internalServer"];
    
    _sessionUrl = [NSString stringWithFormat:@"rtmp://%@/tutormeet/%@_%@/%@_%@?",
                   ip,
                   _connectParams[@"sessionRoomId"],
                   _connectParams[@"sessionSn"],
                   _connectParams[@"sessionSn"],
                   _connectParams[@"userName"]];
    
    [_connectParams enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        _sessionUrl = [_sessionUrl stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, value]];
    }];
    _sessionUrl = [_sessionUrl substringToIndex:([_sessionUrl length] - 1)]; // Remove the last "&"
    
    return _sessionUrl;
}

- (NSString *)_parseRelayServerIp {
    _relayServerIp = nil;
    
    if (_enableRelay && [@"Y" isEqualToString:_classInfo[@"relay"]] && ![_classInfo[@"proxyServer"] isEqualToString:@""])
        _relayServerIp = _classInfo[@"proxyServer"];
    
    return _relayServerIp;
}

- (NSString *)_parseTutorConsoleUrl {
    _tutorConsoleUrl = [NSString stringWithFormat:@"rtmp://%@/tutorconsole/custsupt/custsupt?userName=%@&sessionRoom=%@_%@&role=%@",
                        kTutorConsoleHost,
                        _connectParams[@"userName"],
                        _connectParams[@"sessionRoomId"],
                        _connectParams[@"sessionSn"],
                        _connectParams[@"role"]];
    
    return _tutorConsoleUrl;
}

@end
