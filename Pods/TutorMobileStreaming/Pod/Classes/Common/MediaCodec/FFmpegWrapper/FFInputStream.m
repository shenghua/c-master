//
//  FFInputStream.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFInputStream.h"
#import "FFInputFile.h"

#import "libavutil/timestamp.h"
#import "TutorLog.h"

@interface FFInputStream()

@end

@implementation FFInputStream

- (id)initWithInputFile:(FFInputFile*)newInputFile stream:(AVStream*)newStream {
    if (self = [super initWithFile:newInputFile]) {
        self.stream = newStream;
    }
    return self;
}

- (BOOL)openStream {
    if (_codecCtx) {
        AVCodec *codec = avcodec_find_decoder(_codecCtx->codec_id);
        if(!codec) {
            DDLogDebug(@"Decoder not found !!");
            return NO;
        }
        
        if (avcodec_open2(_codecCtx, codec, NULL) < 0) {
            DDLogDebug(@"Decoder open failed !!");
            return NO;
        }
        
        [self _getAvStreamFpsTimebase];
        
        return YES;
    }
    
    return NO;
}

- (void)closeStream {
    if (_codecCtx) {
        avcodec_close(_codecCtx);
    }
}

- (int)decodePacket:(AVPacket *)packet retFrame:(AVFrame *)frame gotFrame:(int *)gotframe {
    NSAssert(NO, @"No implementation of decodePacket");
    return -1;
}

- (Frame *)handleFrame:(AVFrame *)frame {
    NSAssert(NO, @"No implementation of handleFrame");
    return nil;
}

#pragma mark - Utilities
- (void)_getAvStreamFpsTimebase
{
    NSAssert(self.stream, @"getAvStreamFpsTimebase: st is nil");
    if (!self.stream)
        return;
    
    if (self.stream->time_base.den && self.stream->time_base.num)
        _timebase = av_q2d(self.stream->time_base);
    else if(self.stream->codec->time_base.den && self.stream->codec->time_base.num)
        _timebase = av_q2d(self.stream->codec->time_base);
    else
        _timebase = 1000;
    
    if (self.stream->codec->ticks_per_frame != 1) {
        DDLogDebug(@"WARNING: ticks_per_frame = %d", self.stream->codec->ticks_per_frame);
        //_timebase *= self.stream->codec->ticks_per_frame;
    }
    
    if (self.stream->avg_frame_rate.den && self.stream->avg_frame_rate.num)
        _fps = av_q2d(self.stream->avg_frame_rate);
    else if (self.stream->r_frame_rate.den && self.stream->r_frame_rate.num)
        _fps = av_q2d(self.stream->r_frame_rate);
    else
        _fps = 1.0 / _timebase;
}

@end