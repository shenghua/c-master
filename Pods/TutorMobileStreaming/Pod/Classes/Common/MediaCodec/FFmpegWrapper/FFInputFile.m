//
//  FFInputFile.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFInputFile.h"
#import "FFInputStream.h"
#import "FFAudioInputStream.h"
#import "FFVideoInputStream.h"
#import "FFDataInputStream.h"
#import "FFUtilities.h"
#import "TutorLog.h"
#import "AudioManager.h"
#include <libavformat/rtmpproto.h>
#include <libavformat/rtmpproto_backdoor.h>

NSString const *kFFmpegInputFormat = @"flv";

typedef enum _FileStatus {
    FileStatus_NotReady,
    FileStatus_Close,
    FileStatus_Open
} FileStatus;

@interface FFInputFile()
@property (nonatomic, weak) id<FFInputFileDelegate> delegate;
@property (nonatomic, assign) FileStatus status;
@property (nonatomic, assign) int numOfStreams;
@property (nonatomic, assign) int audioStreamIdx;
@property (nonatomic, assign) int videoStreamIdx;
@property (nonatomic, assign) BOOL withAudio;
@property (nonatomic, assign) BOOL withVideo;
@property (nonatomic, weak) AudioManager *audioManager;
@property (nonatomic, weak) NSString *relayServerIp;
@property (nonatomic, weak) BOOL (^interrupt)(void);
@end

@implementation FFInputFile

- (id)initWithPath:(NSString *)path options:(NSDictionary*)options {
    if (self = [super initWithPath:path options:options]) {

        // Init params
        _status = FileStatus_NotReady;
        _audioStreamIdx = -1;
        _videoStreamIdx = -1;
        _withAudio = NO;
        _withVideo = NO;
        if (options && [options objectForKey:@"withAudio"] && [options[@"withAudio"] isEqualToString:@"1"]) // The value must be @"1" or @"0"
            _withAudio = YES;
        if (options && [options objectForKey:@"withVideo"] && [options[@"withVideo"] isEqualToString:@"1"]) // The value must be @"1" or @"0"
            _withVideo = YES;
        if (options && [options objectForKey:@"audioManager"])
            _audioManager = options[@"audioManager"];
        if (options && [options objectForKey:@"relayServerIp"])
            _relayServerIp = options[@"relayServerIp"];
        if (options && [options objectForKey:@"interrupt"])
            _interrupt = options[@"interrupt"];
        if (options && [options objectForKey:@"delegate"])
            _delegate = options[@"delegate"];
        
        // Init formatContext
        self.formatContext = [self _initFormatContext];

        [self _setupStreams];
    }
    return self;
}

- (void)dealloc {
    _status = FileStatus_Close;
    
    @synchronized(self) {
        [self _closeStreams];
        
        AVFormatContext *inputFormatContext = self.formatContext;
        if (inputFormatContext) {
            avformat_close_input(&inputFormatContext);
            self.formatContext = NULL;
        }
    }
}

int interrupt_callback(void *inputFile) {
    if (((__bridge FFInputFile *)inputFile).interrupt() || ((__bridge FFInputFile *)inputFile).status == FileStatus_Close)
        return 1;
    else
        return 0;
}

void server_notify_callback(void *userData, ServerNotify notify, void *data) {
    FFInputFile *inputFile = (__bridge FFInputFile *)userData;
    switch (notify) {
        case ServerNotify_onTimeCodeEvent:
//            DDLogDebug(@"timeCode = %f", *((double *)data));
            if (inputFile.delegate && [inputFile.delegate respondsToSelector:@selector(onTimeCodeEvent:)])
                [inputFile.delegate onTimeCodeEvent:(int)(*((double *)data))];
            break;
            
        case ServerNotify_onCuePointEvent:
//            DDLogDebug(@"cuePoint = %@", [NSString stringWithUTF8String:(char *)data]);
            if (inputFile.delegate && [inputFile.delegate respondsToSelector:@selector(onCuePointEvent:)])
                [inputFile.delegate onCuePointEvent:[NSString stringWithUTF8String:(char *)data]];
            break;
        
        case ServerNotify_onInsufficientBW:
            DDLogDebug(@"InsufficientBW !!");
            if (inputFile.delegate && [inputFile.delegate respondsToSelector:@selector(onInsufficientBW)])
                [inputFile.delegate onInsufficientBW];
            break;
            
        default:
            break;
    }
}

- (AVFormatContext*)_initFormatContext {
    AVFormatContext *inputFormatContext = avformat_alloc_context();
    if (inputFormatContext) {
        // setup interrupt callback
        AVIOInterruptCB cb = {interrupt_callback, (__bridge void *)self};
        inputFormatContext->interrupt_callback = cb;
        
        AVDictionary *inputOptions = NULL;
        // Set option: shared object
//        av_dict_set(&inputOptions, "users_so", "0", 0);
//        av_dict_set(&inputOptions, "webinar_users_so", "0", 0);
        
        // Set option: rtmp_receivevideo
        av_dict_set(&inputOptions, [@"rtmp_receiveaudio" UTF8String], _withAudio ? "1" : "0", 0);
        av_dict_set(&inputOptions, [@"rtmp_receivevideo" UTF8String], _withVideo ? "1" : "0", 0);
        
        // Set option: rtmp_playpath
        // Ex. LiveSession:     rtmp://a.b.c.d/tutormeet/session727_2015101610727/2015101610727_presenter?xxx
        //     RecordedSession: rtmp://a.b.c.d/tutormeetplayback/2015042121001583_null_39/session001583_2015042121001583/2015042121001583_presenter
        
        // playPath is starting behind the 5th '/'
        NSString *playPathWithParams = self.path;
        for (int i = 0; i < 5; i++) {
            NSRange playPathRange = [playPathWithParams rangeOfString:@"/"];
            playPathWithParams = [playPathWithParams substringFromIndex:playPathRange.location + 1];
        }

        NSString *playPathWithoutParams = playPathWithParams;
        NSRange questionMarkRange = [playPathWithParams rangeOfString:@"?"];
        if (questionMarkRange.location != NSNotFound)
            playPathWithoutParams = [playPathWithParams substringToIndex:questionMarkRange.location];
        
        av_dict_set(&inputOptions, [@"rtmp_playpath" UTF8String], [playPathWithoutParams UTF8String], 0);
        
        if (_relayServerIp) {
            // Set relay info
            // @"?rtmp://172.16.7.30/tutormeet/session702_2015120911702"
            NSString *rtmp_app = [NSString stringWithFormat:@"?%@", [self.path substringToIndex:[self.path rangeOfString:playPathWithParams].location - 1]];
            
            // @"rtmp://61.64.50.146/?rtmp://172.16.7.30/tutormeet/session702_2015120911702"
            NSString *rtmp_tcurl = [NSString stringWithFormat:@"rtmp://%@/%@", _relayServerIp, rtmp_app];
            
            av_dict_set(&inputOptions, [@"rtmp_app" UTF8String], [rtmp_app UTF8String], 0);
            av_dict_set(&inputOptions, [@"rtmp_tcurl" UTF8String], [rtmp_tcurl UTF8String], 0);
            
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
        
        // Open input and find stream info
        AVInputFormat *inputFormat = av_find_input_format([kFFmpegInputFormat UTF8String]);
        if (avformat_open_input(&inputFormatContext, [self.path UTF8String], inputFormat, &inputOptions) < 0) {
            avformat_close_input(&inputFormatContext);
            inputFormatContext = NULL;
            DDLogError(@"avformat_open_input failed !!");
        }
        
        // Setup server notify callback
        if (inputFormatContext) {
            SetServerNotifyCallback setServerNotifyCallback;
            setServerNotifyCallback.serverNotifyUserData = (__bridge void *)(self);
            setServerNotifyCallback.serverNotifyCallback = server_notify_callback;
            av_backdoor(inputFormatContext, RTMP_BACKDOOR_CMD_SET_SERVER_NOTIFY_CALLBACK, &setServerNotifyCallback);
        }
        
        if (inputFormatContext) {
            // For H.264 video, sometimes ffmpeg can not fill in extradata when doing avformat_find_stream_info
            // So here we copy the first video packet into extradata by ourselves.
            // The first packet sample data:
            // 0x17:    H264 Keyframe
            // 0x0:     AVC sequence header
            // 0x0 0x0 0x0: No meaning
            // 0x1:     configurationVersion
            // 0x42:    AVCProfileIndication
            // 0x40:    profile_compatibility
            // 0x29:    AVCLevelIndication
            // 0xff:    lengthSizeMinusOne
            // 0xe1:    numOfSequenceParameterSets (numOfSequenceParameterSets & 0x1F)
            // 0x0 0xa: sequenceParameterSetLength
            // 0x27 0x42 0x40 0x29 0x8b 0x95 0x3 0x41 0x3c 0x80:    sequenceParameterSetNALUnits (SPS)
            // 0x1:     numOfPictureParameterSets
            // 0x0 0x4: pictureParameterSetLength
            // 0x28 0xde 0x9 0x88:  pictureParameterSetNALUnits (PPS)
            
            for (int i = 0; i < inputFormatContext->nb_streams; i++) {
                if (_withVideo && inputFormatContext->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
                    AVCodecContext *videoCodecCtx = inputFormatContext->streams[i]->codec;
                    
                    GetStreamInfoContext streamInfoContext;
                    memset(&streamInfoContext, 0, sizeof(GetStreamInfoContext));
                    av_backdoor(inputFormatContext, RTMP_BACKDOOR_CMD_GET_STREAM_INFO, &streamInfoContext);
                    if (streamInfoContext.firstVideoDataLen > 5) {
                        videoCodecCtx->extradata_size = streamInfoContext.firstVideoDataLen - 5;
                        uint8_t *extradata = malloc(videoCodecCtx->extradata_size);
                        memcpy(extradata, streamInfoContext.firstVideoData + 5, videoCodecCtx->extradata_size);
                        if (videoCodecCtx->extradata)
                            free(videoCodecCtx->extradata);
                        videoCodecCtx->extradata = extradata;
                    }
                    
                    break;
                }
            }
            
            inputFormatContext->max_analyze_duration = 50000;   // 0.05 seconds
            
            // avformat_find_stream_info will block until a/v info being found
            if (avformat_find_stream_info(inputFormatContext, NULL) < 0) {
                avformat_close_input(&inputFormatContext);
                inputFormatContext = NULL;
                DDLogError(@"avformat_find_stream_info failed !!");
            }
        }
        
        if (inputOptions)
            av_dict_free(&inputOptions);
    }
    
    return inputFormatContext;
}

- (void)_setupStreams {
    if (self.formatContext) {
        _numOfStreams = self.formatContext->nb_streams;
        NSMutableArray *inputStreams = [NSMutableArray arrayWithCapacity:_numOfStreams];
        
        for (int i = 0; i < _numOfStreams; i++) {
            // codec_type may be: video, audio, data
            DDLogDebug(@"found stream (%s), codec (%s)", av_get_media_type_string(self.formatContext->streams[i]->codec->codec_type),
                                                         avcodec_get_name(self.formatContext->streams[i]->codec->codec_id));
            
            AVStream *inputStream = self.formatContext->streams[i];
            FFInputStream *ffInputStream = nil;
            
            if (_withVideo && self.formatContext->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO && _videoStreamIdx == -1) {
                DDLogDebug(@"_videoStreamIdx = %d", i);
                _videoStreamIdx = i;
                ffInputStream = [[FFVideoInputStream alloc] initWithInputFile:self stream:inputStream];
            }
            
            else if (_withAudio && self.formatContext->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO && _audioStreamIdx == -1) {
                DDLogDebug(@"_audioStreamIdx = %d", i);
                _audioStreamIdx = i;
                ffInputStream = [[FFAudioInputStream alloc] initWithInputFile:self stream:inputStream];
                ((FFAudioInputStream *)ffInputStream).audioManager = _audioManager;
            }
            
            else
                ffInputStream = [[FFDataInputStream alloc] initWithInputFile:self stream:inputStream];
            
            ffInputStream.codecCtx = inputStream->codec;
            [inputStreams addObject:ffInputStream];
        }
        self.streams = inputStreams;
    }
}

// Return NO if all streams can not be opened
- (BOOL)_openStreams {
    if (self.streams.count == 0)
        return NO;
    
    BOOL allFailed = YES;
    for (FFInputStream *ffInputStream in self.streams) {
        if ([ffInputStream openStream])
            allFailed = NO;
        else
            [ffInputStream closeStream];
    }
    
    return !allFailed;
}

- (void)_closeStreams {
    for (FFInputStream *ffInputStream in self.streams) {
        if (ffInputStream)
            [ffInputStream closeStream];
    }
    
    _videoStreamIdx = -1;
    _audioStreamIdx = -1;
}

- (BOOL)openFileForReading {
    _status = FileStatus_Open;
    
    if (![self _openStreams]) {
        [self _closeStreams];
        
        return NO;
    }
    
    return YES;
}

- (Frame *)getFrame {
    if (!self.formatContext)
        return nil;
    
    Frame *frame = nil;
    AVPacket packet;
    AVFrame *avFrame = av_frame_alloc();
    BOOL finished = NO;
    
    while (!finished) {
        @synchronized(self) {
            // Dynamically create streams if new stream found
            if (_numOfStreams != self.formatContext->nb_streams) {
                DDLogDebug(@"recreate streams due to nb_streams changed");
                [self _closeStreams];
                [self _setupStreams];
                [self _openStreams];
            }
        }
        
        @synchronized(self) {
            if (av_read_frame(self.formatContext, &packet) < 0) {
                DDLogDebug(@"av_read_frame failed");
                break;
            }
        }
        
        if (packet.stream_index != _audioStreamIdx && packet.stream_index != _videoStreamIdx)
            continue;
        
        int pktSize = packet.size;
        
        while (pktSize > 0) {
            
            int gotframe = 0;
            int len = [self.streams[packet.stream_index] decodePacket:&packet retFrame:avFrame gotFrame:&gotframe];
            
            if (len < 0) {
                DDLogDebug(@"decode error, skip packet");
                break;
            }
            
            if (gotframe) {
                frame = [self.streams[packet.stream_index] handleFrame:avFrame];
                finished = YES;
            }
            
            if (0 == len)
                break;
            
            pktSize -= len;
        }
    }
    
    av_frame_free(&avFrame);
    av_free_packet(&packet);
    
    return frame;
}

- (BOOL)seek:(CGFloat)position {
    if (self.formatContext)
        av_seek_frame(self.formatContext, -1, position * 1000, 0);
    
    return YES;
}

- (BOOL)pause {
    if (self.formatContext)
        av_read_pause(self.formatContext);
    
    return YES;
}

- (BOOL)resume {
    if (self.formatContext)
        av_read_play(self.formatContext);
    return YES;
}

#pragma mark - Video Stream Info
- (BOOL)setupVideoFrameFormat:(VideoFrameFormat)format {
    if (_videoStreamIdx != -1) {
        FFVideoInputStream *videoInputStream = self.streams[_videoStreamIdx];
        return [videoInputStream setupVideoFrameFormat:format];
    }
    
    return NO;
}

- (CGFloat)getStreamDuration {
    if (self.formatContext)
        return self.formatContext->duration / 1000;
    
    return 0;
}

@end