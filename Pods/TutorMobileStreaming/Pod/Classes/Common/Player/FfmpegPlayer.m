//
//  FfmpegPlayer.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/21.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "FfmpegPlayer.h"
#import "FFInputStream.h"
#import "libavformat/avformat.h"
#import "libavcodec/avcodec.h"
#import "libavutil/opt.h"
#import "TutorLog.h"

static NSString * const kFfmpegPlayerErrorDomain = @"com.tutorabc.FfmepgPlayer";

@interface FfmpegPlayer()
@property (nonatomic, weak) id<FfmpegPlayerDelegate> delegate;
@property (nonatomic, strong) FFInputFile *inputFile;
@property (nonatomic, assign) BOOL withAudio;
@property (nonatomic, assign) BOOL withVideo;
@end

@implementation FfmpegPlayer
@dynamic frameWidth;
@dynamic frameHeight;

- (id)initWithUrl:(NSString *)url
         delegate:(id<FfmpegPlayerDelegate>)delegate
        withAudio:(BOOL)withAudio
        withVideo:(BOOL)withVideo
     audioManager:(AudioManager *)audioManager
    relayServerIp:(NSString *)relayServerIp
        interrupt:(BOOL (^)(void))interrupt {
    
    if (self = [super init]) {
        av_register_all();
        avformat_network_init();
        avcodec_register_all();
        
#if DEBUG
        av_log_set_level(AV_LOG_DEBUG);
#else
        av_log_set_level(AV_LOG_QUIET);
#endif
        _delegate = delegate;
        [self _setupInputFileWithUrl:url withAudio:withAudio withVideo:withVideo audioManager:audioManager relayServerIp:relayServerIp interrupt:interrupt];
    }
    return self;
}

- (void)_setupInputFileWithUrl:(NSString *)url withAudio:(BOOL)withAudio withVideo:(BOOL)withVideo audioManager:(AudioManager *)audioManager relayServerIp:(NSString *)relayServerIp interrupt:(BOOL (^)(void))interrupt {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    options[@"withAudio"] = withAudio ? @"1" : @"0";
    options[@"withVideo"] = withVideo ? @"1" : @"0";
    if (audioManager)
        options[@"audioManager"] = audioManager;
    if (relayServerIp)
        options[@"relayServerIp"] = relayServerIp;
    if (interrupt)
        options[@"interrupt"] = interrupt;
    
    options[@"delegate"] = self;
    
    _inputFile = [[FFInputFile alloc] initWithPath:url options:options];
}

- (BOOL)prepareForPlaying:(NSError *__autoreleasing *)error {
    // Open the input file for reading packets
    if (!_inputFile || ![_inputFile openFileForReading]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:kFfmpegPlayerErrorDomain code:0 userInfo:nil];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)finishPlaying:(NSError *__autoreleasing *)error {
    _inputFile = nil;
    
    return YES;
}

- (Frame *)getFrame {
    if (_inputFile) {
        return [_inputFile getFrame];
    }
    
    return nil;
}

- (BOOL)seek:(CGFloat)position {
    if (_inputFile) {
        return [_inputFile seek:position];
    }
    
    return NO;
}

- (BOOL)pause {
    if (_inputFile) {
        return [_inputFile pause];
    }
    
    return NO;
}

- (BOOL)resume {
    if (_inputFile) {
        return [_inputFile resume];
    }
    
    return NO;
}

#pragma mark - FFInputFileDelegate handler
- (void)onTimeCodeEvent:(int)event {
    if (_delegate && [_delegate respondsToSelector:@selector(onTimeCodeEvent:)])
        [_delegate onTimeCodeEvent:event];
}

- (void)onCuePointEvent:(NSString *)event {
    if (_delegate && [_delegate respondsToSelector:@selector(onCuePointEvent:)])
        [_delegate onCuePointEvent:event];
}

- (void)onInsufficientBW {
    if (_delegate && [_delegate respondsToSelector:@selector(onInsufficientBW)])
        [_delegate onInsufficientBW];
}

#pragma mark - Video Info
- (BOOL)setupVideoFrameFormat:(VideoFrameFormat)format {
    if (_inputFile) {
        return [_inputFile setupVideoFrameFormat:format];
    }

    return NO;
}

- (CGFloat)getStreamDuration {
    if (_inputFile) {
        return [_inputFile getStreamDuration];
    }
    
    return 0;
}

@end
