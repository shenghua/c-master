//
//  Streamer.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/6/29.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KFEncoder.h"

typedef enum _CameraPosition {
    CameraPosition_None,
    CameraPosition_Front,
    CameraPosition_Back,
} CameraPosition;

@class Streamer;

@protocol StreamerDelegate <NSObject>
@end

/**
 *  Streamer manages the majority of the AV pipeline
 */
@interface Streamer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, KFEncoderDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic) BOOL isStreaming;
@property (nonatomic, weak) id<StreamerDelegate> delegate;
@property (nonatomic, assign) float microphoneGain;
@property (nonatomic, assign) BOOL microphoneMute;
@property (nonatomic, assign) CameraPosition cameraPosition;

- (id)initWithUrl:(NSString *)url withAudio:(BOOL)withAudio withVideo:(BOOL)withVideo relayServerIp:(NSString *)relayServerIp;
- (BOOL)startStreaming;
- (BOOL)stopStreaming;

@end
