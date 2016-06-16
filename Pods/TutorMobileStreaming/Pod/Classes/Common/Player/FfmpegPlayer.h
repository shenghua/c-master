//
//  FfmpegPlayer.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/21.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FFFrameType.h"
#import "FFInputFile.h"
#import "AudioManager.h"

@protocol FfmpegPlayerDelegate <NSObject>
- (void)onTimeCodeEvent:(int)event;
- (void)onCuePointEvent:(NSString *)event;
- (void)onInsufficientBW;
@end

@interface FfmpegPlayer : NSObject <FFInputFileDelegate>

@property (readonly, nonatomic) NSUInteger frameWidth;
@property (readonly, nonatomic) NSUInteger frameHeight;

- (id)initWithUrl:(NSString*)url
         delegate:(id<FfmpegPlayerDelegate>)delegate
        withAudio:(BOOL)withAudio
        withVideo:(BOOL)withVideo
     audioManager:(AudioManager *)audioManager
    relayServerIp:(NSString *)relayServerIp
        interrupt:(BOOL (^)(void))interrupt;
- (BOOL)prepareForPlaying:(NSError**)error;
- (BOOL)finishPlaying:(NSError**)error;
- (Frame *)getFrame;
- (BOOL)seek:(CGFloat)position;
- (BOOL)pause;
- (BOOL)resume;

- (BOOL)setupVideoFrameFormat:(VideoFrameFormat)format;
- (CGFloat)getStreamDuration;
@end
