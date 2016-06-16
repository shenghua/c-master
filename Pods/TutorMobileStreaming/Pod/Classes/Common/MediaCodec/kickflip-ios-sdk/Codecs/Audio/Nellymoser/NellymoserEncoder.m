//
//  NellymoserEncoder.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/25.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "NellymoserEncoder.h"
#import "KFFrame.h"
#import "libavformat/avformat.h"
#import "libavcodec/avcodec.h"
#import "libswresample/swresample.h"

#define kDumpAudio NO
#define kPcmDumpFileName @"dump.pcm"
#define kSampleSize 4

@interface NellymoserEncoder()
@property (nonatomic) AVCodecContext    *pCodecCtx;
@property (nonatomic) AVCodec           *pCodec;
@property (nonatomic) AVFrame           *pFrame;
@property (nonatomic) AVPacket          pkt;
@property (nonatomic) SwrContext        *swrContext;
@property (nonatomic) uint8_t           *swrBuffer;
@property (nonatomic) NSUInteger        swrBufferSize;
@property (nonatomic) uint8_t           *pcmBuffer;
@property (nonatomic) size_t            pcmBufferSize;
@property (nonatomic) uint8_t           *remainingSampleBuffer;
@property (nonatomic) size_t            remainingSampleCount;
@end

@implementation NellymoserEncoder

- (void)dealloc {
    [self _closeResampler];
}

- (instancetype)initWithBitrate:(NSUInteger)bitrate sampleRate:(NSUInteger)sampleRate channels:(NSUInteger)channels {
    if (self = [super initWithBitrate:bitrate sampleRate:sampleRate channels:channels]) {
        self.encoderQueue = dispatch_queue_create("Nellymoser Encoder Queue", DISPATCH_QUEUE_SERIAL);
        _pcmBufferSize = 0;
        _pcmBuffer = NULL;
        _remainingSampleBuffer = NULL;
        _remainingSampleCount = 0;
        
        av_register_all();

        [self _setupEncoder];
    }
    return self;
}

- (void)_setupEncoder {
    _pCodec = avcodec_find_encoder(AV_CODEC_ID_NELLYMOSER);
    _pCodecCtx = avcodec_alloc_context3(_pCodec);
    _pCodecCtx->codec_type = AVMEDIA_TYPE_AUDIO;
    _pCodecCtx->sample_fmt = AV_SAMPLE_FMT_FLT;
    _pCodecCtx->sample_rate = (int)self.sampleRate;
    _pCodecCtx->channel_layout = (self.channels == 1) ? AV_CH_LAYOUT_MONO : AV_CH_LAYOUT_STEREO;
    _pCodecCtx->channels = av_get_channel_layout_nb_channels(_pCodecCtx->channel_layout);
    _pCodecCtx->bit_rate = (int)self.bitrate;
    
    avcodec_open2(_pCodecCtx, _pCodec, NULL);
    
    _pFrame = av_frame_alloc();
    _pFrame->nb_samples     = _pCodecCtx->frame_size;       // 256
    _pFrame->format         = _pCodecCtx->sample_fmt;       // AV_SAMPLE_FMT_FLT
    _pFrame->channel_layout = _pCodecCtx->channel_layout;
    _pFrame->channels       = _pCodecCtx->channels;
}

- (BOOL)_setupResamplerWithSampleRate:(NSUInteger)sampleRate channels:(NSUInteger)channels {
    _swrContext = swr_alloc_set_opts(NULL,
                                     av_get_default_channel_layout(_pCodecCtx->channels),   // out_ch_layout
                                     _pCodecCtx->sample_fmt,                                // out_sample_fmt
                                     _pCodecCtx->sample_rate,                               // out_sample_rate
                                     av_get_default_channel_layout((int)channels),          // in_ch_layout
                                     AV_SAMPLE_FMT_S16,                                     // in_sample_fmt
                                     (int)sampleRate,                                       // in_sample_rate
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
    
    if (_remainingSampleBuffer) {
        free(_remainingSampleBuffer);
        _remainingSampleBuffer = NULL;
    }
}

- (int)_doResampling {
    const int bufSize = (int)_pcmBufferSize * 2;
    if (!_swrBuffer || _swrBufferSize < bufSize) {
        _swrBufferSize = bufSize;
        _swrBuffer = realloc(_swrBuffer, _swrBufferSize);
    }
    
    Byte *outbuf[2] = { _swrBuffer, 0 };
    int numSamples = swr_convert(_swrContext,
                                 outbuf,                           // output buffer
                                 (int)_pcmBufferSize / 2,          // output sample count
                                 (const uint8_t **)(&_pcmBuffer),  // input buffer
                                 (int)_pcmBufferSize / 2);         // input sample count
    return numSamples;
}

- (void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CFRetain(sampleBuffer);
    dispatch_async(self.encoderQueue, ^{
        AudioStreamBasicDescription audioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
        
        if (!_swrContext) {
            [self _setupResamplerWithSampleRate:audioStreamBasicDescription.mSampleRate channels:audioStreamBasicDescription.mChannelsPerFrame];
        }
        
        // Get PCM data pointer from sampleBuffer
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &_pcmBufferSize, (char **)(&_pcmBuffer));
        NSError *error = nil;
        if (status != kCMBlockBufferNoErr) {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        // Debug
        [self _dumpPcm:_pcmBuffer bufferLen:_pcmBufferSize];
        
        // Resample pcm data from AV_SAMPLE_FMT_S16 to AV_SAMPLE_FMT_FLT
        int sampleCount = [self _doResampling];
        
        // Fill in processingBuffer with remaining and new resampled data
        int processingSampleCount = _remainingSampleCount + sampleCount;
        size_t processingSampleBufSize = processingSampleCount * kSampleSize;
        uint8_t *processingSampleBuf = malloc(processingSampleBufSize);
        if (_remainingSampleBuffer)
            memcpy(processingSampleBuf, _remainingSampleBuffer, _remainingSampleCount * kSampleSize);
        memcpy(processingSampleBuf + _remainingSampleCount * kSampleSize, _swrBuffer, sampleCount * kSampleSize);
        
        // Encode PCM data to Nellymoser
        NSMutableData *encodedData;
        int frameSize = _pFrame->nb_samples * kSampleSize;   // AV_SAMPLE_FMT_FLT -> 4 bytes
        int frameCount = processingSampleCount / _pFrame->nb_samples;
        
        for (int i = 0; i < frameCount; i++) {
            av_init_packet(&_pkt);
            _pkt.data = NULL;       // packet data will be allocated by the encoder
            _pkt.size = 0;
            
            int got_frame = 0;
            _pFrame->data[0] = processingSampleBuf + i * frameSize;
            avcodec_encode_audio2(_pCodecCtx, &_pkt, _pFrame, &got_frame);
            
            if (got_frame == 1) {
                if (!encodedData)
                    encodedData = [NSMutableData dataWithBytes:_pkt.data length:_pkt.size];
                else
                    [encodedData appendBytes:_pkt.data length:_pkt.size];
                
                av_free_packet(&_pkt);
            }
            
            processingSampleCount -= _pFrame->nb_samples;
        }
        
        // Collect remaining samples
        if (processingSampleCount) {
            if (_remainingSampleBuffer)
                free(_remainingSampleBuffer);
            
            _remainingSampleCount = processingSampleCount;
            _remainingSampleBuffer = malloc(_remainingSampleCount * kSampleSize);
            
            memcpy(_remainingSampleBuffer, processingSampleBuf + frameCount * frameSize, _remainingSampleCount * kSampleSize);
        }
        
        if (processingSampleBuf)
            free(processingSampleBuf);
        
        // Callback encoded frame
        if (self.delegate && encodedData) {
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            KFFrame *frame = [[KFFrame alloc] initWithData:encodedData pts:pts];
            dispatch_async(self.callbackQueue, ^{
                [self.delegate encoder:self encodedFrame:frame];
            });
        }
        
        CFRelease(sampleBuffer);
        CFRelease(blockBuffer);
   });
}

#pragma mark - Utilities
- (void)_dumpPcm:(uint8_t *)buffer bufferLen:(size_t)bufferLen {
    // Dump raw data to file
    if (kDumpAudio) {
        NSData *data = [NSData dataWithBytes:buffer
                                      length:bufferLen];
        
        [self _dumpData:data fileName:kPcmDumpFileName];
    }
}

- (void)_dumpData:(NSData *)data fileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *pcmDumpFilePath = [libraryDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:pcmDumpFilePath]) {
        [data writeToFile:pcmDumpFilePath atomically:YES];
    }
    else {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:pcmDumpFilePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
    }
}

@end
