//
//  Player.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/22.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import <UIKit/UIApplication.h>
#import "Player.h"
#import "TutorLog.h"
#import "AudioManager.h"

#define kDefaultAudioSampleRate 11025
#define kLiveAudioFramesMaxLength 25    // For kDefaultAudioSampleRate
#define kRecordedAudioFramesMaxLength 2000
#define kVideoAudioMaxDiffPos 0.2   // video.position - audio.position

#define kNoFrameGotDuration 5

@interface Player()
@property (nonatomic, strong) NSString          *url;
@property (nonatomic, weak) id<PlayerDelegate>  delegate;
@property (nonatomic, assign) BOOL              withAudio;
@property (nonatomic, assign) BOOL              withVideo;
@property (nonatomic, assign) BOOL              liveMode;
@property (nonatomic, strong) NSString          *relayServerIp;
@property (nonatomic, assign) BOOL              interrupt;
@property (nonatomic, strong) FfmpegPlayer      *ffmpegPlayer;
@property (nonatomic, strong) AudioManager      *audioManager;
@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, strong) NSMutableArray    *audioFrames;
@property (nonatomic, assign) int               audioFramesMaxLength;
@property (nonatomic, strong) NSMutableArray    *videoFrames;
@property (nonatomic, strong) AudioFrame        *currentAudioFrame;     // Store the current audio frame to be filled into AudioManager
@property (nonatomic, assign) NSUInteger        currentAudioFramePos;   // Store the pos of the current audio frame to be filled
@property (nonatomic, assign) CGFloat           currentAudioPosition;   // Store the position of the Audio currently played
@property (nonatomic, assign) NSUInteger        audioPosInBufToBeAdded;      // Store the position of the audio buffer to be added
@property (nonatomic, assign) NSUInteger        audioPosInBufToBeConsumed;   // Store the position of the audio buffer to be consumed
@property (nonatomic, strong) NSTimer           *oneSecondTimer;
@property (nonatomic, assign) int               displayedAccuVideoFrameCount;   // Displayed accumulated video frame count
@property (nonatomic, assign) CGFloat           audioManagerVolumeFactor;
@property (nonatomic, strong) NSDate            *latestGotFrameTime;
@end

@implementation Player
@synthesize volumeFactor = _volumeFactor;
@synthesize spkrVolFactor = _spkrVolFactor;

- (id)initWithUrl:(NSString *)url
         delegate:(id<PlayerDelegate>)delegate
        withAudio:(BOOL)withAudio
        withVideo:(BOOL)withVideo
         liveMode:(BOOL)liveMode
         userName:(NSString *)userName
             role:(NSString *)role
    relayServerIp:(NSString *)relayServerIp {
    
    if (self = [super init]) {
        _url = [url copy];
        _delegate = delegate;
        _withAudio = withAudio;
        _withVideo = withVideo;
        _liveMode = liveMode;
        _userName = [userName copy];
        _role = [role copy];
        _relayServerIp = [relayServerIp copy];
        _interrupt = NO;
        
        _videoFrames = [NSMutableArray array];
        _audioPosInBufToBeAdded = 0;
        _audioPosInBufToBeConsumed = 0;
        
        _timeCodeEventQueue = [NSMutableArray new];
        _timeCode = -1;
        _prevSeekPos = -1;
        
        _playerStatus = PlayerStatus_Stopped;
    }
    return self;
}

- (void)_setupVideoView {
    if (!_ffmpegPlayer)
        return;
    
    [_ffmpegPlayer setupVideoFrameFormat:VideoFrameFormatRGB];
    _imageView = [UIImageView new];
    _imageView.backgroundColor = [UIColor blackColor];

    UIView *videoView = [self videoView];
    videoView.contentMode = UIViewContentModeScaleAspectFill;
    videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
}

- (UIView *)videoView {
    return _imageView;
}

#pragma mark - Audio Manager operation
- (void)_setupAudioManager {
    _audioManager = [AudioManager new];
    if (_audioManager) {
        _audioManager.delegate = self;
        DDLogDebug(@"_setupAudioManager success");

        _audioManagerVolumeFactor = _audioManager.volumeFactor;
        _volumeFactor = _audioManager.volumeFactor;
        _spkrVolFactor = 1.0;
    }
    else
        DDLogDebug(@"_setupAudioManager fail");
}

- (void)audioCallbackFillData:(float *)outData
                    numFrames:(UInt32)numFrames {
    if (_playerStatus == PlayerStatus_Paused) {
        memset(outData, 0, numFrames * _audioManager.numOutputChannels * _audioManager.numBytesPerSample);
        return;
    }
    
    float *outDataStartPos = outData;
    UInt32 numFramesNeeded = numFrames;
    @autoreleasepool {
        while (numFramesNeeded > 0) {
            if (!_currentAudioFrame) {
                @synchronized(_audioFrames) {
                    
                    if (![_audioFrames[_audioPosInBufToBeConsumed] isEqual:[NSNull null]]) {
                        AudioFrame *frame = _audioFrames[_audioPosInBufToBeConsumed];
                        if (frame) {
                            _audioFrames[_audioPosInBufToBeConsumed] = [NSNull null];
                            
                            _currentAudioFramePos = 0;
                            _currentAudioFrame = frame;
                            _currentAudioPosition = _currentAudioFrame.position;
                            
                            // Update _audioPosInBufToBeConsumed
                            _audioPosInBufToBeConsumed++;
                            if (_audioPosInBufToBeConsumed == _audioFramesMaxLength)
                                _audioPosInBufToBeConsumed = 0;
                        }
                    }
                }
            }
            
            @synchronized(_currentAudioFrame) {
                if (_currentAudioFrame && _currentAudioFrame.samples) {
                    _currentPos = _currentAudioFrame.position;
                    
                    const void *bytes = (Byte *)_currentAudioFrame.samples.bytes + _currentAudioFramePos;
                    const NSUInteger bytesLeft = (_currentAudioFrame.samples.length - _currentAudioFramePos);
                    const NSUInteger frameSizeOf = _audioManager.numOutputChannels * _audioManager.numBytesPerSample;
                    const NSUInteger bytesToCopy = MIN(numFramesNeeded * frameSizeOf, bytesLeft);
                    const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                    
                    memcpy(outData, bytes, bytesToCopy);
                    numFramesNeeded -= framesToCopy;
                    outData += framesToCopy * _audioManager.numOutputChannels;
                    
                    if (bytesToCopy < bytesLeft)
                        _currentAudioFramePos += bytesToCopy;
                    else {
                        [_currentAudioFrame free];
                        _currentAudioFrame = nil;
                    }
                    
                } else {
                    memset(outData, 0, numFramesNeeded * _audioManager.numOutputChannels * _audioManager.numBytesPerSample);
                    //                DDLogDebug(@"Wait for audio data");
                    break;
                }
            }
        }
       
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(_videoFrames) {
//                if ([_videoFrames count]) {
//                    DDLogDebug(@"video pos (%f), audio pos (%f), video count (%lu), audio index consumed (%lu), audio index added(%lu)", \
//                               ((Frame *)_videoFrames[0]).position, _currentAudioPosition, [_videoFrames count], _audioPosInBufToBeConsumed, _audioPosInBufToBeAdded);
//                } else {
//                    DDLogDebug(@"audio pos (%f), video count (%lu), audio index consumed (%lu), audio index added(%lu)", \
//                               _currentAudioPosition, [_videoFrames count], _audioPosInBufToBeConsumed, _audioPosInBufToBeAdded);
//                }
                
                // Special case handling: remove the first videoFrame if it's position is larger than the second one
                if ([_videoFrames count] >= 2 && ((Frame *)_videoFrames[0]).position > ((Frame *)_videoFrames[1]).position) {
                    [_videoFrames[0] free];
                    [_videoFrames removeObjectAtIndex:0];
                }
                
                // Display video till video pts >= audio pts
                while ([_videoFrames count] &&
                       (_currentAudioPosition == 0 || ((Frame *)_videoFrames[0]).position - _currentAudioPosition < kVideoAudioMaxDiffPos)) {
                    @autoreleasepool {
                        _imageView.image = [(VideoFrameRGB *)_videoFrames[0] asImage];
                        _displayedAccuVideoFrameCount++;
                    }
                    
                    [_videoFrames[0] free];
                    [_videoFrames removeObjectAtIndex:0];
                }
            }
        });
    }
    
    if (_mute)
        memset(outDataStartPos, 0, numFrames * _audioManager.numOutputChannels * _audioManager.numBytesPerSample);
}

#pragma mark - Player operation

- (BOOL)startPlaying {
    DDLogDebug(@"startPlaying begin (%@)", _userName);
    
    // Init params
    _interrupt = NO;
    _latestGotFrameTime = nil;
    
    // Start one second timer
    _oneSecondTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(_oneSecondTimerCallback:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_oneSecondTimer forMode:NSDefaultRunLoopMode];

    // Setup audio manager
    if (_withAudio)
        [self _setupAudioManager];
    
    // Start player
    _ffmpegPlayer = [[FfmpegPlayer alloc] initWithUrl:_url delegate:self withAudio:_withAudio withVideo:_withVideo audioManager:_audioManager relayServerIp:_relayServerIp interrupt:^BOOL{
        return _interrupt;
    }];
    
    NSError *error = nil;
    if ([_ffmpegPlayer prepareForPlaying:&error]) {
        _playerStatus = PlayerStatus_Playing;
        
        CGFloat streamDuration = [_ffmpegPlayer getStreamDuration];
        if (_delegate && [_delegate respondsToSelector:@selector(onStreamDuration:userName:)])
            [_delegate onStreamDuration:streamDuration userName:_userName];
    }
    else {
        DDLogDebug(@"startPlaying end, error (%@)", error);
        return NO;
    }
    
    if (_withVideo)
        [self _setupVideoView];
    
    // Start audio manager
    if (_audioManager)
        [_audioManager start];
    
    // Setup audioFrames
    if (_audioManager) {
        _audioFramesMaxLength = _liveMode ? kLiveAudioFramesMaxLength : kRecordedAudioFramesMaxLength;
        _audioFramesMaxLength = (int)(_audioManager.samplingRate / kDefaultAudioSampleRate * _audioFramesMaxLength);

        _audioFrames = [NSMutableArray arrayWithCapacity:_audioFramesMaxLength];
        for (int i = 0; i < _audioFramesMaxLength; i++) {
            [_audioFrames addObject:[NSNull null]];
        }
        DDLogDebug(@"Setup audioFrames: %ld", [_audioFrames count]);
    }
    
    // Get and play audio/video frames
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DDLogDebug(@"ReadFrameLoop Start (%@)", _userName);

        while (_ffmpegPlayer && _playerStatus != PlayerStatus_Stopped) {
            @autoreleasepool {
                Frame *frame;
                @synchronized(self) {
                    frame = [_ffmpegPlayer getFrame];
                }

                if (frame) {
                    _latestGotFrameTime = [NSDate date];
                    
                    if (frame.type == FrameTypeVideo) {
                        
                        @synchronized(_videoFrames) {
                            // Append video frame
                            [_videoFrames addObject:frame];
                        }
                    } else if (frame.type == FrameTypeAudio) {
                        @synchronized(_audioFrames) {
//                            DDLogDebug(@"_audioPosInBufToBeConsumed (%ld), audioPosInBufToBeAdded (%ld)", _audioPosInBufToBeConsumed, _audioPosInBufToBeAdded);
                            
                            // 1. Handle full buffer case
                            if (![_audioFrames[_audioPosInBufToBeAdded] isEqual:[NSNull null]]) {
                                DDLogDebug(@"(%@) Audio buffer is full. Remove one frame", _userName);
                                AudioFrame *frame = _audioFrames[_audioPosInBufToBeAdded];
                                [frame free];
                                
                                // Update _audioPosInBufToBeConsumed
                                if (_audioPosInBufToBeConsumed == _audioPosInBufToBeAdded) {
                                    _audioPosInBufToBeConsumed++;
                                    
                                    // Correct _audioPosInBufToBeConsumed position
                                    if (_audioPosInBufToBeConsumed == _audioFramesMaxLength)
                                        _audioPosInBufToBeConsumed = 0;
                                }
                            }
                            
                            // 2. Add audio frame to buffer
                            [_audioFrames replaceObjectAtIndex:_audioPosInBufToBeAdded withObject:frame];
                            _audioPosInBufToBeAdded++;
                            
                            // 3. Correct _audioPosInBufToBeAdded position
                            if (_audioPosInBufToBeAdded == _audioFramesMaxLength)
                                _audioPosInBufToBeAdded = 0;
                        }
                    }
                    
                } else {
                    //DDLogDebug(@"ReadFrameLoop getFrame failed !!");
                    
                    // Will enter here when:
                    // 1. player closed
                    // 2. socket is closed by peer
                    
                    // Here we only callback onGetFrameFailed for the case 2
                    if (_playerStatus != PlayerStatus_Stopped && self.delegate && [self.delegate respondsToSelector:@selector(onGetFrameFailed:)])
                        [self.delegate onGetFrameFailed:_userName];
                    break;
                }
            }
            
        }
        
        DDLogDebug(@"ReadFrameLoop End (%@)", _userName);
    });
    
    DDLogDebug(@"startPlaying end (%@)", _userName);
    return YES;
}

- (void)stopPlaying {
    DDLogDebug(@"stopPlaying begin (%@)", _userName);
    
    _playerStatus = PlayerStatus_Stopped;
    
    // Release one second timer
    if (_oneSecondTimer) {
        [_oneSecondTimer invalidate];
        _oneSecondTimer = nil;
    }
    
    // Release video view
    _imageView = nil;
    
    // Stop audio manager
    if (_audioManager) {
        [_audioManager stop];
        [_audioManager close];
        _audioManager = nil;
    }
    
    // Stop ffmpeg player
    NSError *error = nil;
    _interrupt = YES;
    @synchronized(self) {   // Wait for [_ffmpegPlayer getFrame] finished
        [_ffmpegPlayer finishPlaying:&error];
        _ffmpegPlayer = nil;
    }
    
    // Clear buffer
    [self clearBuffer];
    
     DDLogDebug(@"stopPlaying end (%@) error (%@)", _userName, error);
}

- (void)_clearAudioVideoFrames {
    @synchronized(_audioFrames) {
        for (id frame in _audioFrames) {
            if ([frame isKindOfClass:[AudioFrame class]])
                [frame free];
        }
        [_audioFrames removeAllObjects];

        for (int i = 0; i < _audioFramesMaxLength; i++) {
            [_audioFrames addObject:[NSNull null]];
        }
    }
    
    _audioPosInBufToBeAdded = 0;
    _audioPosInBufToBeConsumed = 0;
    _currentAudioFrame = nil;
    
    @synchronized(_videoFrames) {
        for (id frame in _videoFrames) {
            if ([frame isKindOfClass:[VideoFrame class]])
                [frame free];
        }
        [_videoFrames removeAllObjects];
    }
}

- (void)clearBuffer {
    DDLogDebug(@"clearBuffer (%@)", _userName);
    
    [self _clearAudioVideoFrames];
    
    @synchronized(_timeCodeEventQueue) {
        [_timeCodeEventQueue removeAllObjects];
        _timeCode = -1;
    }
}

- (BOOL)seek:(CGFloat)position {
    DDLogDebug(@"seek: %f (%@)", position, _userName);
    
    if (_playerStatus != PlayerStatus_Stopped && _ffmpegPlayer) {
        [self clearBuffer];
        
        _prevSeekPos = position;
        
        return [_ffmpegPlayer seek:position];
    }
    return NO;
}

- (BOOL)pause {
    DDLogDebug(@"pause (%@)", _userName);
    
    _latestGotFrameTime = nil;
    
    if (_playerStatus != PlayerStatus_Paused && _ffmpegPlayer) {
        _playerStatus = PlayerStatus_Paused;
        return [_ffmpegPlayer pause];
    }
    
    return NO;
}

- (BOOL)resume {
    DDLogDebug(@"resume (%@)", _userName);
    
    if (_playerStatus == PlayerStatus_Paused && _ffmpegPlayer) {
        _playerStatus = PlayerStatus_Playing;
        return [_ffmpegPlayer resume];
    }
    return NO;
}

#pragma mark - FfmpegPlayerDelegate handler
- (void)onTimeCodeEvent:(int)event {
    // Because onTimeCodeEvent is not sent every second, we add it to a queue and then callback on oneSecondTimer
    @synchronized(_timeCodeEventQueue) {
        [_timeCodeEventQueue addObject:@(event)];
    }
}

- (void)onCuePointEvent:(NSString *)event {
    if (_delegate && [_delegate respondsToSelector:@selector(onCuePointEvent:userName:)])
        [_delegate onCuePointEvent:event userName:_userName];
}

- (void)onInsufficientBW {
    if (_delegate && [_delegate respondsToSelector:@selector(onInsufficientBW:)])
        [_delegate onInsufficientBW:_userName];
}

#pragma mark - Volume control
- (void)setVolumeFactor:(float)volumeFactor {
    if (_audioManager) {
        _volumeFactor = volumeFactor;
        _audioManager.volumeFactor = _volumeFactor * _spkrVolFactor;
        
    }
}

- (void)setSpkrVolFactor:(float)spkrVolFactor {
    if (_audioManager) {
        _spkrVolFactor = spkrVolFactor;
        _audioManager.volumeFactor = _volumeFactor * _spkrVolFactor;
    }
}

- (void)setMute:(BOOL)mute {
    if (_audioManager) {
        if (mute) {
            _audioManagerVolumeFactor = _audioManager.volumeFactor;
            _audioManager.volumeFactor = 0;
        } else {
            _audioManager.volumeFactor = _audioManagerVolumeFactor;
        }
        _mute = mute;
    }
}

#pragma mark - Timer
- (void)_oneSecondTimerCallback:(NSTimer *)timer {
    _videoFps = _displayedAccuVideoFrameCount;
    _displayedAccuVideoFrameCount = 0;
    
    // Callback onTimeCodeEvent
    if (_playerStatus == PlayerStatus_Playing &&
        _delegate && [_delegate respondsToSelector:@selector(onTimeCodeEvent:userName:)]) {
        
        int timeCode = -1;
        
        @synchronized(_timeCodeEventQueue) {
            if ([_timeCodeEventQueue count]) {
                timeCode = [_timeCodeEventQueue[0] intValue];
                [_timeCodeEventQueue removeObjectAtIndex:0];
                _timeCode = timeCode;
            }
        }
        
        if (timeCode != -1)
            [_delegate onTimeCodeEvent:timeCode userName:_userName];
    }
    
    // Callback onNoFrameGot
    if (_latestGotFrameTime && [[NSDate date] timeIntervalSinceDate:_latestGotFrameTime] > kNoFrameGotDuration &&
        _delegate && [_delegate respondsToSelector:@selector(onNoFrameGot:)]) {
        
        _latestGotFrameTime = nil;
        DDLogDebug(@"Callback onNoFrameGot since no frame duration is over %d seconds", kNoFrameGotDuration);
        [_delegate onNoFrameGot:_userName];
    }
}

@end