//
//  RecordedSession.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/15.
//
//

#import "RecordedSession.h"
#import "RecordedSessionEvent.h"
#import "RecordedSessionStream.h"
#import "SessionConstants.h"
#import "SessionWhiteboardObject.h"
#import "TutorLog.h"

#define kMaxTimeCodeEventQueueCount 10

@interface RecordedSession ()
@property (nonatomic, strong) NSTimer *oneSecondTimer;
@property (nonatomic, strong) NSDictionary *sessionInfo;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) RecordedWhiteboard *whiteboard;

@property (nonatomic) dispatch_queue_t taskQueue;
@property (nonatomic) dispatch_queue_t concurrentTaskQueue;
@property (nonatomic, assign) BOOL sessionStopped;
@property (nonatomic, strong) RecordedSessionDataParser *recordedSessionDataParser;
@property (nonatomic, strong) NSMutableDictionary *players;     // Store all the players including coordinator, cohost and student

@property (nonatomic, strong) NSDateFormatter *curTimeFormatter;

@property (nonatomic, assign) int whiteboardTotalPages;
@property (nonatomic, assign) int whiteboardPageIdx;

@property (nonatomic, assign) int presenterTimeCode;  // presenter stream position (unit: second, starting from 0)
@property (nonatomic, strong) NSMutableArray *presenterTimeCodeEvents;

@property (nonatomic, assign) long long lastSeekTimestamp;

@property (nonatomic, assign) long long seekPositinoAfterOnSessionStarted;

@end

@implementation RecordedSession
- (instancetype)initSession:(NSDictionary *)sessionInfo
                   delegate:(id<RecordedSessionDelegate>)delegate
                  videoView:(UIView *)videoView
             whiteboardView:(UIView *)whiteboardView {
    self = [super init];
    if (self) {
        // Init Params
        if (!sessionInfo)
            return nil;
        
        DDLogDebug(@"sessionInfo: %@", sessionInfo);
        _sessionInfo = [NSDictionary dictionaryWithDictionary:sessionInfo];
        _delegate = delegate;
        _videoView = videoView;
        if (whiteboardView) {
            _whiteboard = [[RecordedWhiteboard alloc] initWithFrame:CGRectMake(0, 0, whiteboardView.frame.size.width, whiteboardView.frame.size.height)
                                                           delegate:self];
            [_whiteboard setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [whiteboardView addSubview:_whiteboard];
        }
        
        _taskQueue = dispatch_queue_create("RecordedSession Task queue", DISPATCH_QUEUE_SERIAL);
        _concurrentTaskQueue = dispatch_queue_create("RecordedSession Concurrent Task queue", DISPATCH_QUEUE_CONCURRENT);
        
        _curTimeFormatter = [[NSDateFormatter alloc] init];
        [_curTimeFormatter setDateFormat:@"HH:mm:ss"];
        
        _whiteboardTotalPages = 0;
        _whiteboardPageIdx = -1;
        
        _presenterTimeCode = 0;
        _seekPositinoAfterOnSessionStarted = 0;
    }
    return self;
}

- (void)startSession:(long long)position {
    _seekPositinoAfterOnSessionStarted = position;
    
    // Enter classroom
    _sessionStopped = NO;
    
    // Start parsing wb file
    if (!_recordedSessionDataParser)
        _recordedSessionDataParser = [[RecordedSessionDataParser alloc] initWithSessionSn:_sessionInfo[@"sessionSn"]
                                                                                 serverIp:_sessionInfo[@"server"]
                                                                            classStartMin:_sessionInfo[@"classStartMin"]
                                                                                 delegate:self];
    [_recordedSessionDataParser startParser];
    
    // Create player container
    _players = [NSMutableDictionary new];
    
    // Create one second timer
    [self _createOneSecondTimer];
}

- (void)stopSession {
    // Release one second timer
    [self _releaseOneSecondTimer];
    
    // Release all players
    [self _releaseAllPlayers];
    
    // Release RecordedSessionDataParser
    if (_recordedSessionDataParser) {
        [_recordedSessionDataParser stopParser];
        [_recordedSessionDataParser releaseParser];
        _recordedSessionDataParser = nil;
    }
    
    // Stop session
    _sessionStopped = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(onSessionStopped)])
        [_delegate onSessionStopped];
}

- (void)_replayWhiteboardAheadOfTimestamp:(long long)timestamp {
    if (_recordedSessionDataParser) {
        
        // Callback total page number to upper layer
        if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardPageChanged:)]) {
            [_delegate onWhiteboardTotalPages:_recordedSessionDataParser.totalWbPages];
        }
        
        // 1 Clear whiteboard
        if (_whiteboard)
            [_whiteboard clearAllObjects];
        
        // 2. Draw whiteboard shapes
        NSArray *sessionWbObjects = [_recordedSessionDataParser getSessionWbObjectsAheadOfTimestamp:timestamp];
        for (SessionWhiteboardObject *sessionWbObject in sessionWbObjects) {
            if (_whiteboard)
                [_whiteboard addObject:sessionWbObject];
            
            // Callback current page number to upper layer
            if (sessionWbObject.shape == WhiteboardShape_Image && sessionWbObject.objId == 0 &&
                _delegate && [_delegate respondsToSelector:@selector(onWhiteboardPageChanged:)]) {
                
                NSString *fileName = [[sessionWbObject.properties[@(5)] lastPathComponent] stringByDeletingPathExtension];
                [_delegate onWhiteboardPageChanged:[fileName intValue] - 1];
            }
        }
        
        CGPoint position = CGPointZero;
        // 3. Draw whiteboard webPointer
        if ([_recordedSessionDataParser getWebPointerPosAheadOfTimestamp:timestamp point:&position]) {
            if (_whiteboard)
                [_whiteboard webPointerChange:position];
        }
        // 4. Draw whiteboard webMouse
        if ([_recordedSessionDataParser getWebMousePosAheadOfTimestamp:timestamp point:&position]) {
            if (_whiteboard)
                [_whiteboard webMouseChange:position];
        }
    }
}

- (void)_replayChatEventsAheadOfTimestamp:(long long)timestamp {
    if (_recordedSessionDataParser) {
        
        // 1. Clear all chat messages
        if (_delegate && [_delegate respondsToSelector:@selector(onClearAllMessages)])
            [_delegate onClearAllMessages];
        
        // 2. Callback chat messages
        if (_delegate && [_delegate respondsToSelector:@selector(onMessage:)]) {
            NSArray *chatMessges = [_recordedSessionDataParser getChatMessagesAheadOfTimestamp:timestamp];
            if (chatMessges && [chatMessges count])
                [_delegate onMessage:chatMessges];
        }
    }
}

- (void)_replayPlayerFromTimestamp:(long long)timestamp {
    if (_recordedSessionDataParser) {
    
        // Create presenter first
        for (RecordedSessionStream *recordedSessionStream in [_recordedSessionDataParser.recordedSessionStreamList allValues]) {
            if (recordedSessionStream.isPresenter) {
                if (![_players objectForKey:recordedSessionStream.publishName]) {
                    [self _createPlayerByPublishName:recordedSessionStream.publishName isPresenter:recordedSessionStream.isPresenter];
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(onUserIn:isPresenter:)])
                        [_delegate onUserIn:recordedSessionStream.userName isPresenter:recordedSessionStream.isPresenter];
                }
                
                // Seek the first presenter to the timestamp
                long long accuDuration = [self _getAccumulatedDurationAheadOfTimestamp:timestamp recordedSessionStream:recordedSessionStream];
                accuDuration = (accuDuration == 0) ? 1 : accuDuration; // Avoid seeking position to 0 because server will send wrong TimeCode.
                
                [NSThread sleepForTimeInterval:1];  // Workaround crash issue when seeking and getFrame at the same time
                [self _seekPlayerToPosition:(CGFloat)accuDuration publishName:recordedSessionStream.publishName];
                
                break;
            }
        }
        
        // Then create students
        if (!_recordedSessionDataParser.isLobbySession) {
            dispatch_async(_concurrentTaskQueue, ^{
                for (RecordedSessionStream *recordedSessionStream in [_recordedSessionDataParser.recordedSessionStreamList allValues]) {
                    if (!recordedSessionStream.isPresenter) {
                        if (![_players objectForKey:recordedSessionStream.publishName]) {
                            [self _createPlayerByPublishName:recordedSessionStream.publishName isPresenter:recordedSessionStream.isPresenter];
                            
                            if (_delegate && [_delegate respondsToSelector:@selector(onUserIn:isPresenter:)])
                                [_delegate onUserIn:recordedSessionStream.userName isPresenter:recordedSessionStream.isPresenter];
                        }
                    }
                }
            });
        }
    }
}

- (void)_seek:(long long)timestamp {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"timestamp: %lld", timestamp);
        
        // Replay merged whiteboard events ahead of timestamp
        [self _replayWhiteboardAheadOfTimestamp:timestamp];
        
        // Replay all chat events ahead of timestamp
        [self _replayChatEventsAheadOfTimestamp:timestamp];
        
        // Replay players from timestamp
        [self _replayPlayerFromTimestamp:timestamp];

        _lastSeekTimestamp = timestamp;
    });
}

- (void)seek:(long long)position {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"position: %lld", position);

        if (_recordedSessionDataParser) {
            long long timestamp = [self _convertSessionPositionToTimestamp:position userName:kPresenterPublishName];
            if (timestamp)
                [self _seek:timestamp];
        }
    });
}

- (void)pause {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"pause");
        
        @synchronized(_players){
            for (Player *player in [_players allValues]) {
                [player pause];
            }
        }
    });}

- (void)resume {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"resume");
        
        @synchronized(_players){
            for (Player *player in [_players allValues]) {
                [player resume];
            }
        }
    });
}

#pragma mark - Player Controller
- (void)_createPlayerByPublishName:(NSString *)publishName isPresenter:(BOOL)isPresenter {
    @synchronized(_players) {
        // Check if player has already existed
        if ([_players objectForKey:publishName])
            return;
    }
    
    NSString *sessionRoomId = [NSString stringWithFormat:@"session%@", [_sessionInfo[@"sessionSn"] substringFromIndex:10]];
    NSString *playerUrl = [NSString stringWithFormat:@"rtmp://%@/tutormeetplayback/%@_null_%d/%@_%@/%@_%@",
                           _sessionInfo[@"server"],
                           _sessionInfo[@"sessionSn"],
                           arc4random_uniform(1000),
                           sessionRoomId,
                           _sessionInfo[@"sessionSn"],
                           _sessionInfo[@"sessionSn"],
                           publishName];
    Player *player = [self _createPlayer:playerUrl userName:publishName role:@"" withAudio:YES withVideo:isPresenter pause:!isPresenter];
    if (player) {
        @synchronized(_players) {
            [_players setObject:player forKey:publishName];
        }
        
        // Set Video View
        if (isPresenter) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[_videoView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                
                UIView *videoView = [player videoView];
                videoView.frame = _videoView.bounds;
                
                [_videoView insertSubview:videoView atIndex:0];
            });
        }
    }
}

- (Player *)_createPlayer:(NSString *)url userName:(NSString *)userName role:(NSString *)role withAudio:(BOOL)withAudio withVideo:(BOOL)withVideo pause:(BOOL)pause {
    DDLogDebug(@"_createPlayer userName:%@, role: %@, audio: (%d), video: (%d)", userName, role, withAudio, withVideo);
    
    //    NSRange range = [url rangeOfString:@"?"];
    //    if (range.location != NSNotFound)
    //        url = [url substringToIndex:range.location];
    
    Player *player = [[Player alloc] initWithUrl:url delegate:self withAudio:withAudio withVideo:withVideo liveMode:NO userName:userName role:role relayServerIp:nil];
    
    [player startPlaying];
    
    return player;
}

- (void)_releasePlayer:(Player *)player {
    if (player) {
        DDLogDebug(@"_releasePlayer");
        [player stopPlaying];
        player = nil;
    }
}

- (void)_releaseAllPlayers {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"_releaseAllPlayers");
        
        // In order to wait for _createPlayer finished, we use @synchronized here.
        @synchronized(_players){
            for (Player *player in [_players allValues]) {
                [self _releasePlayer:player];
            }
            [_players removeAllObjects];
        }
    });
}

- (void)_seekPlayerToPosition:(CGFloat)position publishName:(NSString *)publishName {
    dispatch_async(_taskQueue, ^{
        @synchronized(_players) {
            Player *player = [_players objectForKey:publishName];
            if (!player)
                return;

            [player seek:(CGFloat)position];
        }
    });
}

- (void)_pausePlayer:(NSString *)publishName {
    dispatch_async(_taskQueue, ^{
        @synchronized(_players) {
            Player *player = [_players objectForKey:publishName];
            if (!player)
                return;
            
            [player pause];
        }
    });
}

- (void)_resumePlayer:(NSString *)publishName {
    dispatch_async(_taskQueue, ^{
        @synchronized(_players) {
            Player *player = [_players objectForKey:publishName];
            if (!player)
                return;
            
            [player resume];
        }
    });
}

#pragma mark - PlayerDelegate handler
- (void)onTimeCodeEvent:(int)event userName:(NSString *)userName {
    DDLogDebug(@"%@: timeCode (%d)", userName, event);
    
    dispatch_async(_taskQueue, ^{
        if (_recordedSessionDataParser) {
            
            // Convert timeCode to timestamp
            long long timestamp = _recordedSessionDataParser.sessionInitTime + event * 1000;
            
            @synchronized(_players) {
                Player *player = [_players objectForKey:userName];
                if (!player)
                    return;
                
                // presenter's onTimeCodeEvent
                if ([kPresenterPublishName isEqualToString:userName]) {
//                    DDLogDebug(@"timeCodeEventQueue count: %ld (%@)", (unsigned long)[player.timeCodeEventQueue count], player.userName);
                    
                    BOOL presenterTimeCodeJump = NO;
                    if (abs(event - _presenterTimeCode) > 1)
                        presenterTimeCodeJump = YES;
                    
                    _presenterTimeCode = event;
                    
                    // Sync students' timeCode to presenter's
                    for (Player *player in [_players allValues]) {
                        if (![kPresenterPublishName isEqualToString:player.userName]) {
                            
                            // Clear player's buffer if buffer too much
//                            DDLogDebug(@"timeCodeEventQueue count: %ld (%@)", (unsigned long)[player.timeCodeEventQueue count], player.userName);
                            if ([player.timeCodeEventQueue count] >= kMaxTimeCodeEventQueueCount) {
                                [player clearBuffer];
                                continue;
                            }
                            
                            int playerTimeCode = player.timeCode;
                            if (playerTimeCode == -1) {
                                if (player.playerStatus == PlayerStatus_Paused) {
                                    DDLogDebug(@"Resume player (%@), player timeCode (%d), presenter timeCode (%d)", player.userName, playerTimeCode, _presenterTimeCode);
                                    [self _resumePlayer:player.userName];
                                }
                                continue;
                            }
                            
                            if (presenterTimeCodeJump) {
                                DDLogDebug(@"Presenter TimeCode (%d) Jump !!", _presenterTimeCode);
                                player.prevSeekPos = -1;
                            }
                            
                            if ((playerTimeCode < _presenterTimeCode - 1) || (playerTimeCode > _presenterTimeCode + 1) || presenterTimeCodeJump) {
                                for (RecordedSessionStream *recordedSessionStream in [_recordedSessionDataParser.recordedSessionStreamList allValues]) {
                                    if ([recordedSessionStream.publishName isEqualToString:player.userName]) {
                                        
                                        // Pause player if player is not faster than presenter over 10 seconds
                                        if (playerTimeCode > _presenterTimeCode && playerTimeCode <= _presenterTimeCode + 10) {
                                            if (player.playerStatus == PlayerStatus_Playing) {
                                                DDLogDebug(@"Pause player (%@), player timeCode (%d), presenter timeCode (%d)", player.userName, playerTimeCode, _presenterTimeCode);
                                                [self _pausePlayer:player.userName];
                                            }
                                        }
                                        // Seek player
                                        else {
                                            // Convert timeCode to playerPosition
                                            // 1. Try to seek the position calculated by wb file (_getAccumulatedDurationAheadOfTimestamp)
                                            // 2. Try to seek the position forecasted by heuristic (previous seek position)
                                            long long playerPosition;
                                            if (player.prevSeekPos != -1) {
                                                if (playerTimeCode < _presenterTimeCode)
                                                    playerPosition = player.prevSeekPos + (_presenterTimeCode - playerTimeCode + 1) * 1000;
                                                else
                                                    playerPosition = player.prevSeekPos - (playerTimeCode - _presenterTimeCode + 1) * 1000;
                                                
                                                if (playerPosition > 0) {
                                                    DDLogDebug(@"Seek player (%@), player timeCode (%d), presenter timeCode (%d), to player position (%lld) according to prevSeekPos (%f)",
                                                               player.userName, playerTimeCode, _presenterTimeCode, playerPosition, player.prevSeekPos);
                                                }
                                            }
                                            else {
                                                playerPosition = [self _getAccumulatedDurationAheadOfTimestamp:timestamp recordedSessionStream:recordedSessionStream];
                                                if (playerPosition > 0)
                                                    DDLogDebug(@"Seek player (%@), player timeCode (%d), presenter timeCode (%d), to player position (%lld) according to timestamp (%lld)",
                                                               player.userName, playerTimeCode, _presenterTimeCode, playerPosition, timestamp);
                                            }
                                            
                                            if (playerPosition > 0) {
                                                if (player.playerStatus == PlayerStatus_Paused)
                                                    [self _resumePlayer:player.userName];
                                                [self _seekPlayerToPosition:playerPosition publishName:player.userName];    // prevSeekPos will be set here
                                            }
                                            else { // timestamp is smaller than player's first record event, pause player
                                                if (player.playerStatus == PlayerStatus_Playing) {
                                                    DDLogDebug(@"Pause player (%@), player timeCode (%d), presenter timeCode (%d)", player.userName, playerTimeCode, _presenterTimeCode);
                                                    [self _pausePlayer:player.userName];
                                                }
                                            }
                                        }
                                        
                                        break;
                                    }
                                }
                            }
                            else {
                                if (player.playerStatus == PlayerStatus_Paused) {
                                    DDLogDebug(@"Resume player (%@), player timeCode (%d), presenter timeCode (%d)", player.userName, playerTimeCode, _presenterTimeCode);
                                    [self _resumePlayer:player.userName];
                                }
                            }
                        }
                    }
                    
                    presenterTimeCodeJump = NO;
                }
            }
            
            // Callback presenter player's position
            if ([kPresenterPublishName isEqualToString:userName] &&
                _delegate && [_delegate respondsToSelector:@selector(onPositionChanged:)]) {
                
                long long presenterPlayerPosition = -1;
                for (RecordedSessionStream *recordedSessionStream in [_recordedSessionDataParser.recordedSessionStreamList allValues]) {
                    if (recordedSessionStream.isPresenter) {
                        presenterPlayerPosition = [self _getAccumulatedDurationFromTimestamp:_recordedSessionDataParser.sessionStartTime
                                                                                 toTimestamp:timestamp
                                                                       recordedSessionStream:recordedSessionStream];
                        break;
                    }
                }
                
                if (presenterPlayerPosition != -1)
                    [_delegate onPositionChanged:presenterPlayerPosition];
            }
        }
    });
}

- (void)onCuePointEvent:(NSString *)event userName:(NSString *)userName {
    // This event is sent by presenter
    DDLogDebug(@"%@: %@", userName, event);
    
    if (!_recordedSessionDataParser)
        return;
    
    // Convert event to RecordedSessionEvent
    // Ex. s-a|7|761|243|250.00|110.00|255|text - text|_sans|6|false|false|false|3
    
    // Replay whiteboard objects and chat events if there is a gap between last replay timestamp and current one
    long long timestamp = 0;
    if (_lastSeekTimestamp != 0) {
        timestamp = [_recordedSessionDataParser getTimestampbyCuePointEvent:event fromTimestamp:_lastSeekTimestamp];
        if (timestamp != 0 && timestamp != _lastSeekTimestamp) {
            [self _replayWhiteboardAheadOfTimestamp:timestamp];
            [self _replayChatEventsAheadOfTimestamp:timestamp];
            _lastSeekTimestamp = 0;
        }
    }
    
    NSArray *infoArray = @[[NSString stringWithFormat:@"%lld", timestamp],
                           [event substringToIndex:1],
                           [event substringFromIndex:2],
                           [NSString stringWithFormat:@"%lld-%@", timestamp, event]];
    
    RecordedSessionEvent *sessionEvent = [[RecordedSessionEvent alloc] initWithInfo:infoArray];
    
    // Convert RecordedSessionEvent to SessionWhiteboardObject and then send to whiteboard
    switch (sessionEvent.eventType) {
        case RecordedSessionEventType_Page:
        case RecordedSessionEventType_Shape:
        {
            if (_whiteboard) {
                [_whiteboard resetWebPointer];
                [_whiteboard resetWebMouse];
            }
            
            SessionWhiteboardObject *sessionWbObject = [_recordedSessionDataParser genSessionWhiteboardObject:sessionEvent];
            
            // Callback current page number to upper layer
            if (sessionWbObject.shape == WhiteboardShape_Image && sessionWbObject.objId == 0) {
                // Clear whiteboard
                if (_whiteboard)
                    [_whiteboard clearAllObjects];
                
                if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardPageChanged:)]) {
                    NSString *fileName = [[sessionWbObject.properties[@(5)] lastPathComponent] stringByDeletingPathExtension];
                    [_delegate onWhiteboardPageChanged:[fileName intValue] - 1];
                }
            }
            
            if (_whiteboard)
                [_whiteboard addObject:sessionWbObject];
            
            break;
        }
        case RecordedSessionEventType_DeleteShape:
        {
            int objId = [sessionEvent.eventParams[0] intValue];
            if (_whiteboard)
                [_whiteboard removeObject:objId];
            break;
        }
        case RecordedSessionEventType_ClearShapes:
        {
            [_whiteboard resetWebPointer];
            [_whiteboard resetWebMouse];
            break;
        }
        case RecordedSessionEventType_Mouse:
        {
            // Ex. m-71|33
            if (_whiteboard) {
                [_whiteboard resetWebPointer];
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                
                CGPoint point;
                point.x = [[f numberFromString:sessionEvent.eventParams[0]] floatValue];
                point.y = [[f numberFromString:sessionEvent.eventParams[1]] floatValue];
            
                [_whiteboard webMouseChange:point];
            }
            break;
        }
        case RecordedSessionEventType_Pointer:
        {
            // Ex. x-102|87
            if (_whiteboard) {
                [_whiteboard resetWebMouse];
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                
                CGPoint point;
                point.x = [[f numberFromString:sessionEvent.eventParams[0]] floatValue];
                point.y = [[f numberFromString:sessionEvent.eventParams[1]] floatValue];
                
                [_whiteboard webPointerChange:point];
            }
            break;
        }
        case RecordedSessionEventType_Chat:
        {
            SessionChatMessage *chatMessage = [_recordedSessionDataParser genChatMessage:sessionEvent];
            if (chatMessage && _delegate && [_delegate respondsToSelector:@selector(onMessage:)]) {
                [_delegate onMessage:@[chatMessage]];
            }

            break;
        }
        default:
            break;
    }
}

- (void)onGetFrameFailed:(NSString *)userName {
    if ([kPresenterPublishName isEqualToString:userName])
        [self stopSession];
    else {
        dispatch_async(_taskQueue, ^{
            @synchronized(_players){
                if ([_players objectForKey:userName]) {
                    Player *player = _players[userName];
                    [player stopPlaying];
                    player = nil;
                    [_players removeObjectForKey:userName];
                }
            }
        });
    }
}
- (void)onStreamDuration:(CGFloat)duration userName:(NSString *)userName {
    //  Callback session duration
    if ([kPresenterPublishName isEqualToString:userName] && _delegate && [_delegate respondsToSelector:@selector(onSessionDuration:)]) {
        
        // Use the smaller one of persenter's stream duration and the one parsed from wb file
        long long presenterAccuDuration = 0;
        
        for (RecordedSessionStream *recordedSessionStream in [_recordedSessionDataParser.recordedSessionStreamList allValues]) {
            if (recordedSessionStream.isPresenter) {
                presenterAccuDuration = [self _getAccumulatedDurationFromTimestamp:_recordedSessionDataParser.sessionStartTime
                                                                       toTimestamp:_recordedSessionDataParser.sessionEndTime
                                                             recordedSessionStream:recordedSessionStream];
                break;
            }
        }
        
        DDLogDebug(@"presenterAccuDuration: %lld, stream duration: %f", presenterAccuDuration, duration);
        [_delegate onSessionDuration:(duration > presenterAccuDuration) ? presenterAccuDuration : duration];
    }
}

#pragma mark - Timer
- (void)_createOneSecondTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
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
    // Callback video fps
    dispatch_async(_taskQueue, ^{
        int fps = 0;
        
        @synchronized(_players) {
            
            if (!_players)
                return;
            
            if ([_players objectForKey:kPresenterPublishName]) {
                Player *player = [_players objectForKey:kPresenterPublishName];
                fps = player.videoFps;
            }
        };
        
//        DDLogDebug(@"Video FPS: %d", fps);
        if (_delegate && [_delegate respondsToSelector:@selector(onVideoFps:)])
            [_delegate onVideoFps:fps];
    });
    
    // Callback current player position
    if (_recordedSessionDataParser && _recordedSessionDataParser.isLobbySession) {
        dispatch_async(_taskQueue, ^{
            long long playerPosition = 0;
            
            @synchronized(_players) {
                if (!_players)
                    return;
                
                if ([_players objectForKey:kPresenterPublishName]) {
                    Player *player = [_players objectForKey:kPresenterPublishName];
                    playerPosition = (int)player.currentPos * 1000;
                }
            };
//            DDLogDebug(@"Current position: %lld", playerPosition);
            if (_recordedSessionDataParser && _delegate && [_delegate respondsToSelector:@selector(onPositionChanged:)]) {
                for (RecordedSessionStream *recordedSessionStream in [_recordedSessionDataParser.recordedSessionStreamList allValues]) {
                    if (recordedSessionStream.isPresenter) {
                        long long positionGap = _recordedSessionDataParser.sessionStartTime - recordedSessionStream.startTime;
                        [_delegate onPositionChanged:playerPosition - positionGap];
                        
                        break;
                    }
                }
            }
        });
    }
}

#pragma mark - RecordedSessionDataParserDelegate handler
- (void)onRecordedSessionDataParserDone:(BOOL)success {
    DDLogDebug(@"success: %d", success);
    if (_delegate && [_delegate respondsToSelector:@selector(onSessionStarted:)])
        [_delegate onSessionStarted:success];
    
    if (!success)
        return;

    dispatch_async(_taskQueue, ^{
        // Seek to session start time or _seekPositinoAfterOnSessionStarted
        if (_recordedSessionDataParser) {
            if (_seekPositinoAfterOnSessionStarted > 0) {
                long long timestamp = [self _convertSessionPositionToTimestamp:_seekPositinoAfterOnSessionStarted userName:kPresenterPublishName];
                [self _seek:timestamp];
            }
            else
                [self _seek:_recordedSessionDataParser.sessionStartTime];
        }
    });
}

#pragma mark - Utilities
- (long long)_getAccumulatedDurationAheadOfTimestamp:(long long)timestamp recordedSessionStream:(RecordedSessionStream *)sessionStream {
    if (!sessionStream)
        return 0;
    
    long long accuDuration = 0;
    long long enterTime = 0;
    for (NSArray *enterLeaveArr in sessionStream.enterLeaveTimeList) {
        if ([enterLeaveArr[0] longLongValue] > timestamp)
            break;
        
        if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Enter"] && enterTime == 0) {
            enterTime = [enterLeaveArr[0] longLongValue];
        } else if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Leave"] && enterTime != 0) {
            accuDuration += ([enterLeaveArr[0] longLongValue] - enterTime);
            enterTime = 0;
        }
    }
    
    if (enterTime != 0)
        accuDuration += (timestamp - enterTime);
    
    return accuDuration;
}

- (long long)_getAccumulatedDurationFromTimestamp:(long long)fromTimestamp toTimestamp:(long long)toTimestamp recordedSessionStream:(RecordedSessionStream *)sessionStream {
    if (!sessionStream)
        return 0;
    
//    DDLogDebug(@"fromTimestamp (%lld), toTimestamp (%lld)", fromTimestamp, toTimestamp);
    
    long long accuDuration = 0;
    long long enterTime = 0;
    for (NSArray *enterLeaveArr in sessionStream.enterLeaveTimeList) {
//        DDLogDebug(@"%lld, %@", [enterLeaveArr[0] longLongValue], (NSString *)enterLeaveArr[1]);
        
        if ([enterLeaveArr[0] longLongValue] < fromTimestamp) {
            if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Enter"]) {
                enterTime = fromTimestamp;
//                DDLogDebug(@"enterTime = %lld", enterTime);
            }
            
            continue;
        }
        
        if ([enterLeaveArr[0] longLongValue] > toTimestamp) {
            if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Leave"] && enterTime == 0) {
                enterTime = fromTimestamp;
//                DDLogDebug(@"enterTime = %lld", enterTime);
            }
            break;
        }
        
        if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Enter"] && enterTime == 0) {
            enterTime = [enterLeaveArr[0] longLongValue];
//            DDLogDebug(@"enterTime = %lld", enterTime);
        }
        else if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Leave"]) {
            if (enterTime == 0) {
                enterTime = fromTimestamp;
//                DDLogDebug(@"enterTime = %lld", enterTime);
            }
            
//            DDLogDebug(@"accuDuration (%lld) += leave (%lld) - enterTime (%lld)", accuDuration, [enterLeaveArr[0] longLongValue], enterTime);
            accuDuration += ([enterLeaveArr[0] longLongValue] - enterTime);
            enterTime = 0;
        }
    }
    
    if (enterTime != 0) {
//        DDLogDebug(@"accuDuration (%lld) += toTimestamp (%lld) - enterTime (%lld)", accuDuration, toTimestamp, enterTime);
        accuDuration += (toTimestamp - enterTime);
    }
    
//    DDLogDebug(@"accuDuration (%lld)", accuDuration);
    return accuDuration;
}

- (long long)_convertSessionPositionToTimestamp:(long long)position userName:(NSString *)userName {
    long long timestamp = 0;
    
    if (_recordedSessionDataParser) {
        long long accuDuration = 0;
        long long enterTime = 0;
        for (RecordedSessionStream *recordedSessionStream in [_recordedSessionDataParser.recordedSessionStreamList allValues]) {
            if ([recordedSessionStream.publishName isEqualToString:userName]) {
                for (NSArray *enterLeaveArr in recordedSessionStream.enterLeaveTimeList) {
                    // From session start time
                    if ([enterLeaveArr[0] longLongValue] < _recordedSessionDataParser.sessionStartTime) {
                        if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Enter"])
                            enterTime = _recordedSessionDataParser.sessionStartTime;
                        continue;
                    }
                    
                    if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Enter"] && enterTime == 0) {
                        enterTime = [enterLeaveArr[0] longLongValue];
                    }
                    else if ([(NSString *)enterLeaveArr[1] isEqualToString:@"Leave"]) {
                        if (enterTime == 0)
                            enterTime = _recordedSessionDataParser.sessionStartTime;
                        
                        accuDuration += ([enterLeaveArr[0] longLongValue] - enterTime);
                        enterTime = 0;
                        
                        if (accuDuration >= position) {
                            timestamp = [enterLeaveArr[0] longLongValue] - (accuDuration - position);
                            break;
                        }
                    }
                }
                
                break;
            }
        }
        
        if (enterTime != 0) {
            accuDuration += (_recordedSessionDataParser.sessionEndTime - enterTime);
            
            if (accuDuration >= position)
                timestamp = _recordedSessionDataParser.sessionEndTime - (accuDuration - position);
        }
    }
    
    return timestamp;
}

@end
