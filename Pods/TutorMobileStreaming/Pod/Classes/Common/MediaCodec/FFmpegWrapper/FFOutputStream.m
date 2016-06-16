//
//  FFOutputStream.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFOutputStream.h"
#import "FFOutputFile.h"
#import "TutorLog.h"

@implementation FFOutputStream
@synthesize lastMuxDTS, frameNumber;

- (id) initWithOutputFile:(FFOutputFile*)outputFile {
    if (self = [super initWithFile:outputFile]) {
        self.lastMuxDTS = AV_NOPTS_VALUE;
        self.frameNumber = 0;
        
        self.stream = avformat_new_stream(outputFile.formatContext, NULL);
        [outputFile addOutputStream:self];
    }
    return self;
}

- (void) setupVideoContextWithWidth:(int)width height:(int)height bitrate:(int)bitrate extradata:(NSData *)extradata {
    AVCodecContext *codecContext = self.stream->codec;
    avcodec_get_context_defaults3(codecContext, NULL);
    codecContext->codec_id = CODEC_ID_H264;
    codecContext->codec_type = AVMEDIA_TYPE_VIDEO;
    codecContext->width    = width;
	codecContext->height   = height;
    codecContext->bit_rate = bitrate;
    codecContext->profile = FF_PROFILE_H264_BASELINE;
    codecContext->time_base.den = 30;
	codecContext->time_base.num = 1;
    codecContext->pix_fmt       = PIX_FMT_YUV420P;
	if (self.parentFile.formatContext->oformat->flags & AVFMT_GLOBALHEADER)
		codecContext->flags |= CODEC_FLAG_GLOBAL_HEADER;
    
    codecContext->extradata_size = (int)[extradata length];
    codecContext->extradata = av_malloc(codecContext->extradata_size);
    memcpy(codecContext->extradata, [extradata bytes], codecContext->extradata_size);
    
    DDLogDebug(@"setupVideoContext width = (%d), height = (%d), bitrate = %d", width, height, bitrate);
    for (int i = 0; i < codecContext->extradata_size; i++)
        DDLogDebug(@"Video extradata[%d] = 0x%x", i, codecContext->extradata[i]);
}

- (void) setupAudioAACContextWithSampleRate:(int)sampleRate bitrate:(int)bitrate extradata:(NSData *)extradata {
    AVCodecContext *codecContext = self.stream->codec;
    avcodec_get_context_defaults3(codecContext, NULL);
	codecContext->codec_id = CODEC_ID_AAC;
	codecContext->codec_type = AVMEDIA_TYPE_AUDIO;
	codecContext->strict_std_compliance = FF_COMPLIANCE_UNOFFICIAL; // for native aac support
	codecContext->sample_fmt  = AV_SAMPLE_FMT_FLT;
	codecContext->time_base.den = sampleRate;
	codecContext->time_base.num = 1;
    codecContext->channel_layout = AV_CH_LAYOUT_MONO;
    codecContext->profile = FF_PROFILE_AAC_LOW;
    codecContext->bit_rate = bitrate;
	codecContext->sample_rate = sampleRate;
	codecContext->channels    = 1;
	if (self.parentFile.formatContext->oformat->flags & AVFMT_GLOBALHEADER)
		codecContext->flags |= CODEC_FLAG_GLOBAL_HEADER;
    
    codecContext->extradata_size = (int)[extradata length];
    codecContext->extradata = av_malloc(codecContext->extradata_size);
    memcpy(codecContext->extradata, [extradata bytes], codecContext->extradata_size);
    
    DDLogDebug(@"setupAudioContext sampleRate = (%d), bitrate = (%d),", sampleRate, bitrate);
    for (int i = 0; i < codecContext->extradata_size; i++)
        DDLogDebug(@"Audio extradata[%d] = 0x%x", i, codecContext->extradata[i]);
}

- (void) setupAudioNellymoserContextWithSampleRate:(int)sampleRate bitrate:(int)bitrate extradata:(NSData *)extradata {
    AVCodecContext *codecContext = self.stream->codec;
    avcodec_get_context_defaults3(codecContext, NULL);
    codecContext->codec_id = CODEC_ID_NELLYMOSER;
    codecContext->codec_type = AVMEDIA_TYPE_AUDIO;
    codecContext->sample_fmt  = AV_SAMPLE_FMT_FLT;
    codecContext->time_base.den = sampleRate;
    codecContext->time_base.num = 1;
    codecContext->channel_layout = AV_CH_LAYOUT_MONO;
    codecContext->bit_rate = bitrate;
    codecContext->sample_rate = sampleRate;
    codecContext->channels    = 1;
}

@end