//
//  FFAudioInputStream.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/30.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "FFAudioInputStream.h"
#import "libswresample/swresample.h"
#import "TutorLog.h"
#import "AudioManager.h"
#import <Accelerate/Accelerate.h>

#define kDumpAudio  NO
#define kPcmDumpFileName @"dump.pcm"

@interface FFAudioInputStream()
@property (nonatomic) SwrContext    *swrContext;
@property (nonatomic) void          *swrBuffer;
@property (nonatomic) NSUInteger    swrBufferSize;
@end

@implementation FFAudioInputStream

- (BOOL)_audioCodecIsSupported {
    DDLogDebug(@"AudioManager samplingRate = %f, channels = %d", self.audioManager.samplingRate, self.audioManager.numOutputChannels);
    
    if (self.audioManager && self.codecCtx->sample_fmt == AV_SAMPLE_FMT_FLT) {
        
        if (self.audioManager.samplingRate == self.codecCtx->sample_rate && self.audioManager.numOutputChannels == self.codecCtx->channels)
            return YES;
        
        if ([self.audioManager updateAudioParams:self.codecCtx->channels samplingRate:self.codecCtx->sample_rate])
            return YES;
    }
    
    return NO;
}

- (BOOL)openStream {
    if (![super openStream]) {
        DDLogDebug(@"Open Auido stream failed !!");
        return NO;
    }
    
    // Create resampler if necessary
    if (![self _audioCodecIsSupported]) {
        if (![self _setupResampler]) {
            
            DDLogDebug(@"Failed to create Resampler");
            return NO;
        }
    }
    
    DDLogDebug(@"Audio codec info: sample rate (%.d), format: (%d), chn: %d",
               self.codecCtx->sample_rate,
               self.codecCtx->sample_fmt,
               self.codecCtx->channels);
    
    return YES;
}

- (void)closeStream {
    [super closeStream];
    
    [self _closeResampler];
}

- (int)decodePacket:(AVPacket *)packet retFrame:(AVFrame *)frame gotFrame:(int *)gotframe {
    if (self.stream->codec)
        return avcodec_decode_audio4(self.stream->codec, frame, gotframe, packet);
    return -1;
}

- (Frame *)handleFrame:(AVFrame *)avFrame {
    if (!avFrame->data[0] || !self.codecCtx || !self.audioManager)
        return nil;
    
    NSInteger numFrames;
    void *audioData;
    
    // Resampling audio frame
    if (_swrContext) {
        const float ratio = (1.0 * self.audioManager.samplingRate / self.codecCtx->sample_rate) *
                (self.audioManager.numOutputChannels / self.codecCtx->channels);

        const int bufSize = av_samples_get_buffer_size(NULL,
                                                       self.audioManager.numOutputChannels,
                                                       avFrame->nb_samples * ratio,
                                                       AV_SAMPLE_FMT_FLT,
                                                       1);
        
        if (!_swrBuffer || _swrBufferSize < bufSize) {
            _swrBufferSize = bufSize;
            _swrBuffer = realloc(_swrBuffer, _swrBufferSize);
        }
        
        Byte *outbuf[2] = { _swrBuffer, 0 };
        numFrames = swr_convert(_swrContext,
                                outbuf,                             // output buffer
                                avFrame->nb_samples * ratio,        // output sample count
                                (const uint8_t **)avFrame->data,    // input buffer
                                avFrame->nb_samples);               // input sample count
        
        if (numFrames < 0) {
            DDLogDebug(@"Fail to resample audio !!");
            return nil;
        }
        
        audioData = _swrBuffer;
        
    } else {
        if (self.codecCtx->sample_fmt != AV_SAMPLE_FMT_FLT) {
            NSAssert(false, @"Audio sample format is not acceptable");
            return nil;
        }
        
        audioData = avFrame->data[0];
        numFrames = avFrame->nb_samples;
    }
    
    // Fill audio data/info into AudioFrame
    AudioFrame *frame = [[AudioFrame alloc] init];
    NSUInteger bytesToCopy = numFrames * self.audioManager.numOutputChannels * self.audioManager.numBytesPerSample;
    
    frame.samples = [NSData dataWithBytes:audioData
                                   length:bytesToCopy];
    frame.position = av_frame_get_best_effort_timestamp(avFrame) * self.timebase;
    frame.duration = av_frame_get_pkt_duration(avFrame) * self.timebase;
    
    if (frame.duration == 0) {
        frame.duration = frame.samples.length / (self.audioManager.numBytesPerSample * self.audioManager.numOutputChannels * self.audioManager.samplingRate);
    }

    // Dump raw data to file
    if (kDumpAudio) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        NSString *pcmDumpFilePath = [libraryDirectory stringByAppendingPathComponent:kPcmDumpFileName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:pcmDumpFilePath]) {
            [frame.samples writeToFile:pcmDumpFilePath atomically:YES];
        }
        else {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:pcmDumpFilePath];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:frame.samples];
        }
    }
    
    return frame;
}

#pragma mark - Resampler operation
- (BOOL)_setupResampler {
    if (!self.audioManager)
        return NO;
    
    _swrContext = swr_alloc_set_opts(NULL,
                                     av_get_default_channel_layout(self.audioManager.numOutputChannels),
                                     AV_SAMPLE_FMT_FLT,
                                     self.audioManager.samplingRate,
                                     av_get_default_channel_layout(self.codecCtx->channels),
                                     self.codecCtx->sample_fmt,
                                     self.codecCtx->sample_rate,
                                     0,
                                     NULL);
    
    if (!_swrContext || swr_init(_swrContext)) {
        if (_swrContext)
            swr_free(&_swrContext);

        return NO;
    }

    return YES;
}

- (void)_closeResampler {
    if (_swrBuffer) {
        free(_swrBuffer);
        _swrBuffer = NULL;
        _swrBufferSize = 0;
    }
    
    if (_swrContext) {
        swr_free(&_swrContext);
        _swrContext = NULL;
    }
}

@end
