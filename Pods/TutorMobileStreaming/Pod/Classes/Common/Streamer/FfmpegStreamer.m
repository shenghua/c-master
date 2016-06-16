//
//  FfmpegStreamer.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/6/30.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "FfmpegStreamer.h"
#import "FFOutputFile.h"
#import "libavformat/avformat.h"
#import "libavcodec/avcodec.h"
#import "libavutil/opt.h"
#import "TutorLog.h"

@interface FfmpegStreamer()
@property (nonatomic, strong) FFOutputFile *outputFile;
@property (nonatomic, strong) FFOutputStream *videoStream;
@property (nonatomic, strong) FFOutputStream *audioStream;
@property (nonatomic) AVPacket *packet;
@property (nonatomic) AVRational videoTimeBase;
@property (nonatomic) AVRational audioTimeBase;
@end

@implementation FfmpegStreamer

- (id)initWithUrl:(NSString *)url relayServerIp:(NSString *)relayServerIp {
    if (self = [super init]) {        
        av_register_all();
        avformat_network_init();
        avcodec_register_all();
        
#if DEBUG
        av_log_set_level(AV_LOG_DEBUG);
#else
        av_log_set_level(AV_LOG_QUIET);
#endif
        
        _url = url;
        _packet = av_malloc(sizeof(AVPacket));
        _videoTimeBase.num = 1;
        _videoTimeBase.den = 1000000000;
        _audioTimeBase.num = 1;
        _audioTimeBase.den = 1000000000;
        [self _setupOutputFile:relayServerIp];
        _conversionQueue = dispatch_queue_create("FfmpegStreamer queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)_setupOutputFile:(NSString *)relayServerIp {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    if (relayServerIp)
        options[@"relayServerIp"] = relayServerIp;
    _outputFile = [[FFOutputFile alloc] initWithPath:_url options:options];
    
    FFBitstreamFilter *bitstreamFilter = [[FFBitstreamFilter alloc] initWithFilterName:@"aac_adtstoasc"];
    [_outputFile addBitstreamFilter:bitstreamFilter];
}

- (void)addVideoStreamWithWidth:(int)width height:(int)height bitrate:(int)bitrate extradata:(NSData *)extradata {
    if (_outputFile) {
        _videoStream = [[FFOutputStream alloc] initWithOutputFile:_outputFile];
        [_videoStream setupVideoContextWithWidth:width height:height bitrate:bitrate extradata:extradata];
        self.videoStreamIndex = (unsigned int)[_outputFile.streams count] - 1;
    }
}

- (void)addAudioStreamWithAudioFormat:(AudioFormat)audioFormat sampleRate:(int)sampleRate bitrate:(int)bitrate extradata:(NSData *)extradata {
    if (_outputFile) {
        _audioStream = [[FFOutputStream alloc] initWithOutputFile:_outputFile];
        if (audioFormat == AudioFormat_AAC)
            [_audioStream setupAudioAACContextWithSampleRate:sampleRate bitrate:bitrate extradata:extradata];
        else
            [_audioStream setupAudioNellymoserContextWithSampleRate:sampleRate bitrate:bitrate extradata:extradata];
        self.audioStreamIndex = (unsigned int)[_outputFile.streams count] - 1;
    }
}

- (BOOL)prepareForStreaming:(NSError *__autoreleasing *)error {
    // Open the output file for streaming and write header
    if (_outputFile &&
        (![_outputFile openFileForWritingWithError:error] ||
        ![_outputFile writeHeaderWithError:error])) {
        return NO;
    }
    
    return YES;
}

- (BOOL)finishStreaming:(NSError *__autoreleasing *)error {
    // Write trailer and close the output file
    if (_outputFile &&
        ![_outputFile writeTrailerWithError:error]) {
        return NO;
    }
    _outputFile = nil;
    
    return YES;
}

- (void)processEncodedData:(NSData*)data presentationTimestamp:(CMTime)pts streamIndex:(unsigned int)streamIndex isKeyFrame:(BOOL)isKeyFrame {
    if (data.length == 0) {
        return;
    }
    dispatch_async(_conversionQueue, ^{
        if (!_outputFile)
            return;
        
        av_init_packet(_packet);
        
        uint64_t originalPTS = pts.value;
        
        // This lets the muxer know about H264 keyframes
        if (streamIndex == self.videoStreamIndex && isKeyFrame) { // this is hardcoded to video right now
            _packet->flags |= AV_PKT_FLAG_KEY;
        }
        
        _packet->data = (uint8_t*)data.bytes;
        _packet->size = (int)data.length;
        _packet->stream_index = streamIndex;
        uint64_t scaledPTS = av_rescale_q(originalPTS, _videoTimeBase, _outputFile.formatContext->streams[_packet->stream_index]->time_base);
        //DDLogInfo(@"*** Scaled PTS: %lld", scaledPTS);
        
        _packet->pts = scaledPTS;
        _packet->dts = scaledPTS;
        NSError *error = nil;
        [_outputFile writePacket:_packet error:&error];

        if (error) {
            DDLogError(@"Error writing packet at streamIndex %d and PTS %lld: %@", streamIndex, originalPTS, error.description);
        } else {
//            DDLogVerbose(@"Wrote packet of length %d at streamIndex %d and \t oPTS %lld \t scaledPTS %lld", (int)data.length, streamIndex, originalPTS, scaledPTS);
        }
    });
}

@end
