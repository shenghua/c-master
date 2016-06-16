//
//  FFVideoInputStream.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/30.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "FFVideoInputStream.h"
#import "TutorLog.h"
#include <libswscale/swscale.h>

@interface FFVideoInputStream()
@property (nonatomic) struct SwsContext *swsContext;
@property (nonatomic) AVPicture         picture;
@property (nonatomic) BOOL              isPictureValid;
@property (nonatomic) VideoFrameFormat  videoFrameFormat;
@end

@implementation FFVideoInputStream

- (BOOL)openStream {    
    if (![super openStream]) {
        DDLogDebug(@"Open Video stream failed !!");
        return NO;
    }
    
    return YES;
}

- (void)closeStream {
    [super closeStream];

    [self _closeScaler];
}

// Return YES if _videoFrameFormat is set to VideoFrameFormatYUV
// Return NO  if _videoFrameFormat is set to VideoFrameFormatRGB
- (BOOL)setupVideoFrameFormat:(VideoFrameFormat)format
{
    if (format == VideoFrameFormatYUV && self.codecCtx &&
        (self.codecCtx->pix_fmt == AV_PIX_FMT_YUV420P || self.codecCtx->pix_fmt == AV_PIX_FMT_YUVJ420P)) {
        
        _videoFrameFormat = VideoFrameFormatYUV;
        return YES;
    }
    
    _videoFrameFormat = VideoFrameFormatRGB;
    return _videoFrameFormat == format;
}

- (int)decodePacket:(AVPacket *)packet retFrame:(AVFrame *)frame gotFrame:(int *)gotframe {
    if (self.codecCtx)
        return avcodec_decode_video2(self.codecCtx, frame, gotframe, packet);
    return -1;
}

- (Frame *)handleFrame:(AVFrame *)avFrame {
    if (!avFrame->data[0] || !self.codecCtx)
        return nil;
    
    VideoFrame *frame;
    if (_videoFrameFormat == VideoFrameFormatYUV) {
        VideoFrameYUV *yuvFrame = [[VideoFrameYUV alloc] init];
        
        yuvFrame.luma = copyFrameData(avFrame->data[0],
                                      avFrame->linesize[0],
                                      self.codecCtx->width,
                                      self.codecCtx->height);
        yuvFrame.chromaB = copyFrameData(avFrame->data[1],
                                         avFrame->linesize[1],
                                         self.codecCtx->width / 2,
                                         self.codecCtx->height / 2);
        yuvFrame.chromaR = copyFrameData(avFrame->data[2],
                                         avFrame->linesize[2],
                                         self.codecCtx->width / 2,
                                         self.codecCtx->height / 2);
        frame = yuvFrame;
    } else {
        [self _closeScaler];
        if (!_swsContext &&
            ![self _setupScaler]) {
            
            DDLogDebug(@"Setup video scaler failed !!");
            return nil;
        }
        
        sws_scale(_swsContext,
                  (const uint8_t **)avFrame->data,
                  avFrame->linesize,
                  0,
                  self.codecCtx->height,
                  _picture.data,
                  _picture.linesize);
        
        VideoFrameRGB *rgbFrame = [[VideoFrameRGB alloc] init];
        rgbFrame.linesize = _picture.linesize[0];
        rgbFrame.rgb = [NSData dataWithBytes:_picture.data[0]
                                      length:rgbFrame.linesize * self.codecCtx->height];
        frame = rgbFrame;
    }
    
    frame.width = self.codecCtx->width;
    frame.height = self.codecCtx->height;
    frame.position = av_frame_get_best_effort_timestamp(avFrame) * self.timebase;
    
    const int64_t frameDuration = av_frame_get_pkt_duration(avFrame);
    if (frameDuration) {
        frame.duration = frameDuration * self.timebase;
        frame.duration += avFrame->repeat_pict * self.timebase * 0.5;
    } else {
        // sometimes, ffmpeg unable to determine a frame duration
        // as example yuvj420p stream from web camera
        frame.duration = 1.0 / self.fps;
    }
    
    return frame;
}

#pragma mark - Scaler operation
- (void)_closeScaler
{
    if (_swsContext) {
        sws_freeContext(_swsContext);
        _swsContext = NULL;
    }
    
    if (_isPictureValid) {
        avpicture_free(&_picture);
        _isPictureValid = NO;
    }
}

- (BOOL)_setupScaler
{
    [self _closeScaler];
    
    _isPictureValid = avpicture_alloc(&_picture,
                                      PIX_FMT_RGB24,
                                      self.codecCtx->width,
                                      self.codecCtx->height) == 0;
    
    if (!_isPictureValid)
        return NO;
    
    _swsContext = sws_getCachedContext(_swsContext,
                                       self.codecCtx->width,
                                       self.codecCtx->height,
                                       self.codecCtx->pix_fmt,
                                       self.codecCtx->width,
                                       self.codecCtx->height,
                                       PIX_FMT_RGB24,
                                       SWS_FAST_BILINEAR,
                                       NULL, NULL, NULL);
    
    return _swsContext != NULL;
}

#pragma mark - Utilities
static NSData *copyFrameData(UInt8 *src, int linesize, int width, int height)
{
    width = MIN(linesize, width);
    NSMutableData *md = [NSMutableData dataWithLength: width * height];
    Byte *dst = md.mutableBytes;
    for (NSUInteger i = 0; i < height; ++i) {
        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return md;
}

@end
