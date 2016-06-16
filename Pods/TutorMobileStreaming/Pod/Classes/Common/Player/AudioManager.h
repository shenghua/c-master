//
//  AudioManager.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/3.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

@protocol AudioManagerDelegate <NSObject>
@required
- (void)audioCallbackFillData:(float *)outData numFrames:(UInt32)numFrames;
@end

@interface AudioManager : NSObject
- (void)start;
- (void)stop;
- (void)close;
- (BOOL)updateAudioParams:(UInt32)numOutputChannels samplingRate:(Float64)samplingRate;

@property (nonatomic, weak) id<AudioManagerDelegate> delegate;
@property (nonatomic, readonly) const UInt32  numOutputChannels;
@property (nonatomic, readonly) const Float64 samplingRate;
@property (nonatomic, readonly) const UInt32  numBytesPerSample;
@property (nonatomic, assign) float  volumeFactor;
@end
