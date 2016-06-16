//
//  FfmpegStreamer.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/6/30.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum _AudioFormat {
    AudioFormat_AAC,
    AudioFormat_Nellymoser
} AudioFormat;

@interface FfmpegStreamer : NSObject

@property (nonatomic) dispatch_queue_t conversionQueue;
@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, assign) unsigned int videoStreamIndex;
@property (nonatomic, assign) unsigned int audioStreamIndex;

- (id) initWithUrl:(NSString*)url relayServerIp:(NSString *)relayServerIp;

- (void) addVideoStreamWithWidth:(int)width height:(int)height bitrate:(int)bitrate extradata:(NSData *)extradata;
- (void) addAudioStreamWithAudioFormat:(AudioFormat)audioFormat sampleRate:(int)sampleRate bitrate:(int)bitrate extradata:(NSData *)extradata;

- (BOOL) prepareForStreaming:(NSError**)error;

- (void) processEncodedData:(NSData*)data presentationTimestamp:(CMTime)pts streamIndex:(unsigned int)streamIndex isKeyFrame:(BOOL)isKeyFrame;

- (BOOL) finishStreaming:(NSError**)error;

@end
