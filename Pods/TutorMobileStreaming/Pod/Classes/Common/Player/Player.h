//
//  Player.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/22.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioManager.h"
#import "FfmpegPlayer.h"

typedef enum _PlayerStatus {
    PlayerStatus_Stopped,
    PlayerStatus_Paused,
    PlayerStatus_Playing,
} PlayerStatus;

@class Player;

@protocol PlayerDelegate <NSObject>
- (void)onTimeCodeEvent:(int)event userName:(NSString *)userName;
- (void)onCuePointEvent:(NSString *)event userName:(NSString *)userName;
- (void)onGetFrameFailed:(NSString *)userName;
- (void)onNoFrameGot:(NSString *)userName;
- (void)onStreamDuration:(CGFloat)duration userName:(NSString *)userName; // millisecond
- (void)onInsufficientBW:(NSString *)userName;
@end

/**
 *  Player manages the majority of the AV playback
 */
@interface Player : NSObject <AudioManagerDelegate, FfmpegPlayerDelegate>

@property (nonatomic, assign) PlayerStatus playerStatus;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, assign) float volumeFactor;
@property (nonatomic, assign) float spkrVolFactor;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign, readonly) int videoFps;
@property (nonatomic, assign, readonly) int timeCode;       // for non-lobby session to do player synchronization
@property (nonatomic, strong) NSMutableArray *timeCodeEventQueue;
@property (nonatomic, assign) CGFloat prevSeekPos;          // millisecond, for non-lobby session to do player synchronization
@property (nonatomic, assign, readonly) CGFloat currentPos; // for lobby session
@property (nonatomic, strong) NSDate *getFrameFailedStartTime;

/**
 *  This method will block until player being initialized. Please provide interrupt block to break this method.
 */
- (id)initWithUrl:(NSString *)url
         delegate:(id<PlayerDelegate>)delegate
        withAudio:(BOOL)withAudio
        withVideo:(BOOL)withVideo
         liveMode:(BOOL)liveMode
         userName:(NSString *)userName
             role:(NSString *)role
    relayServerIp:(NSString *)relayServerIp;  // Used to determine if using relay or not
- (BOOL)startPlaying;
- (void)stopPlaying;
- (BOOL)seek:(CGFloat)position; // millisecond, starting from 0
- (BOOL)pause;
- (BOOL)resume;
- (void)clearBuffer;

- (UIView *)videoView;
@end
