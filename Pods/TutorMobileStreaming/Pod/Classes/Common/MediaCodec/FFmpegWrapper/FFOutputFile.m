//
//  FFOutputFile.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFOutputFile.h"
#import "FFUtilities.h"

#import "libavutil/timestamp.h"

NSString const *kFFmpegOutputFormat = @"flv";

@interface FFOutputFile()
@property (nonatomic, strong, readwrite) NSMutableSet *bitstreamFilters;
@property (nonatomic, weak) NSString *relayServerIp;
@end

@implementation FFOutputFile

- (void) addBitstreamFilter:(FFBitstreamFilter *)bitstreamFilter {
    [_bitstreamFilters addObject:bitstreamFilter];
}

- (void) removeBitstreamFilter:(FFBitstreamFilter *)bitstreamFilter {
    [_bitstreamFilters removeObject:bitstreamFilter];
}

- (void) dealloc {
    avio_close(self.formatContext->pb);
    avformat_free_context(self.formatContext);
}

- (AVFormatContext*) formatContextForOutputPath:(NSString*)outputPath options:(NSDictionary*)options {
    AVFormatContext *outputFormatContext = NULL;
    
    int openOutputValue = avformat_alloc_output_context2(&outputFormatContext, NULL, [kFFmpegOutputFormat UTF8String], [outputPath UTF8String]);
    if (openOutputValue < 0) {
        avformat_free_context(outputFormatContext);
        return nil;
    }
    return outputFormatContext;
}

- (void) addOutputStream:(FFOutputStream*)outputStream {
    [self.streams addObject:outputStream];
}

- (id) initWithPath:(NSString *)path options:(NSDictionary *)options {
    if (self = [super initWithPath:path options:options]) {
        self.formatContext = [self formatContextForOutputPath:path options:options];
        self.streams = [NSMutableArray array];
        _bitstreamFilters = [NSMutableSet set];
        
        if (options && options[@"relayServerIp"])
            _relayServerIp = options[@"relayServerIp"];
    }
    return self;
}

- (BOOL) openFileForWritingWithError:(NSError *__autoreleasing *)error {
    /* open the output file, if needed */
    if (!(self.formatContext->oformat->flags & AVFMT_NOFILE)) {

        // Set option: rtmp_playpath
        NSString *playPathWithParams = [self.path lastPathComponent];
        NSString *playPathWithoutParams = playPathWithParams;
        NSRange questionMarkRange = [playPathWithParams rangeOfString:@"?"];
        if (questionMarkRange.location != NSNotFound)
            playPathWithoutParams = [playPathWithParams substringToIndex:questionMarkRange.location];
        
        AVDictionary *options = NULL;
        av_dict_set(&options, [@"rtmp_playpath" UTF8String], [playPathWithoutParams UTF8String], 0);
        
        if (_relayServerIp) {
            // Set relay info
            // @"?rtmp://172.16.7.30/tutormeet/session702_2015120911702"
            NSString *rtmp_app = [NSString stringWithFormat:@"?%@", [self.path substringToIndex:[self.path rangeOfString:playPathWithParams].location - 1]];
            
            // @"rtmp://61.64.50.146/?rtmp://172.16.7.30/tutormeet/session702_2015120911702"
            NSString *rtmp_tcurl = [NSString stringWithFormat:@"rtmp://%@/%@", _relayServerIp, rtmp_app];
            
            av_dict_set(&options, [@"rtmp_app" UTF8String], [rtmp_app UTF8String], 0);
            av_dict_set(&options, [@"rtmp_tcurl" UTF8String], [rtmp_tcurl UTF8String], 0);
            
            // Replace self.path's server ip with relay ip
            // Find server ip's end position (the 3rd '/')
            int count = 0;
            int serverIpEndPos = -1;
            for (int i = 0; i < [self.path length]; ++i) {
                if ([self.path characterAtIndex:i] == '/') {
                    ++count;
                    if (count == 3) {
                        serverIpEndPos = i;
                        break;
                    }
                }
            }
            
            self.path = [NSString stringWithFormat:@"rtmp://%@%@", _relayServerIp, [self.path substringFromIndex:serverIpEndPos]];
        }
        
        int returnValue = avio_open2(&self.formatContext->pb, [self.path UTF8String], AVIO_FLAG_WRITE, NULL, &options);
        if (returnValue < 0) {
            if (error != NULL) {
                *error = [FFUtilities errorForAVError:returnValue];
            }
            av_dict_free(&options);
            return NO;
        }
        av_dict_free(&options);
    }
    return YES;
}

- (BOOL) writeHeaderWithError:(NSError *__autoreleasing *)error {
    AVDictionary *options = NULL;
    
    // Write header for output file
    int writeHeaderValue = avformat_write_header(self.formatContext, &options);
    if (writeHeaderValue < 0) {
        if (error != NULL) {
            *error = [FFUtilities errorForAVError:writeHeaderValue];
        }
        av_dict_free(&options);
        return NO;
    }
    av_dict_free(&options);
    return YES;
}

- (AVPacket) applyBitstreamFilter:(AVBitStreamFilterContext*)bitstreamFilterContext packet:(AVPacket*)packet outputCodecContext:(AVCodecContext*)outputCodecContext {
    AVPacket newPacket = *packet;
    int a = av_bitstream_filter_filter(bitstreamFilterContext, outputCodecContext, NULL,
                                       &newPacket.data, &newPacket.size,
                                       packet->data, packet->size,
                                       packet->flags & AV_PKT_FLAG_KEY);
    if(a == 0 && newPacket.data != packet->data && newPacket.destruct) {
        uint8_t *t = av_malloc(newPacket.size + FF_INPUT_BUFFER_PADDING_SIZE); //the new should be a subset of the old so cannot overflow
        if(t) {
            memcpy(t, newPacket.data, newPacket.size);
            memset(t + newPacket.size, 0, FF_INPUT_BUFFER_PADDING_SIZE);
            newPacket.data = t;
            newPacket.buf = NULL;
            a = 1;
        } else {
            a = AVERROR(ENOMEM);
        }
        
    }
    if (a > 0) {
        av_free_packet(packet);
        newPacket.buf = av_buffer_create(newPacket.data, newPacket.size,
                                         av_buffer_default_free, NULL, 0);
        if (!newPacket.buf) {
            NSLog(@"new packet buffer couldnt be allocated");
        }
        
    } else if (a < 0) {
        NSLog(@"FFmpeg Error: Failed to open bitstream filter %s for stream %d with codec %s", bitstreamFilterContext->filter->name, packet->stream_index,
              outputCodecContext->codec ? outputCodecContext->codec->name : "copy");
    }
    return newPacket;
}

- (BOOL) writePacket:(AVPacket *)packet error:(NSError *__autoreleasing *)error {
    if (!packet) {
        NSLog(@"NULL packet!");
        return NO;
    }
    FFOutputStream *ffOutputStream = [self.streams objectAtIndex:packet->stream_index];
    AVStream *outputStream = ffOutputStream.stream;
    
    AVCodecContext *outputCodecContext = outputStream->codec;
    
    if (outputCodecContext->codec_id == AV_CODEC_ID_AAC) {
        for (FFBitstreamFilter *bsf in _bitstreamFilters) {
            AVPacket newPacket = [self applyBitstreamFilter:bsf.bitstreamFilterContext packet:packet outputCodecContext:outputCodecContext];
            av_free_packet(packet);
            packet = &newPacket;
        }
    }
    
    ffOutputStream.lastMuxDTS = packet->dts;
    
    int writeFrameValue = av_interleaved_write_frame(self.formatContext, packet);
    if (writeFrameValue < 0) {
        if (error != NULL) {
            *error = [FFUtilities errorForAVError:writeFrameValue];
        }
        return NO;
    }
    outputStream->codec->frame_number++;
    return YES;
}

- (BOOL) writeTrailerWithError:(NSError *__autoreleasing *)error {
    int writeTrailerValue = av_write_trailer(self.formatContext);
    if (writeTrailerValue < 0) {
        if (error != NULL) {
            *error = [FFUtilities errorForAVError:writeTrailerValue];
        }
        return NO;
    }
    return YES;
}

@end