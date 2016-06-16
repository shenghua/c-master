//
//  Streamer.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/6/29.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//
#import <UIKit/UIDevice.h>
#import <UIKit/UIApplication.h>
#import "Streamer.h"
#import "KFAACEncoder.h"
#import "NellymoserEncoder.h"
#import "KFH264Encoder.h"
#import "KFFrame.h"
#import "KFVideoFrame.h"
#import "FfmpegStreamer.h"
#import "TutorLog.h"

#define kUseAudioHwEncode NO    // YES: AAC (44100), NO: Nellymoser (11025/16000/22050/44100)

static const int kVideoWith         = 320;//512;
static const int kVideoHeight       = 320;//384;
static const int kVideoBitrate      = 192 * 1024;
static const int kAudioSampleRate   = 16000;
static const int kAudioBitrate      = 32 * 1024;
static const int kAudioChannels     = 1;

@interface Streamer()
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) dispatch_queue_t audioQueue;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) KFEncoder *audioEncoder;  // AAC or Nellymoser depends on kUseAudioHwEncode
@property (nonatomic, strong) KFH264Encoder *h264Encoder;
@property (nonatomic, strong) FfmpegStreamer *ffmpegStreamer;

@property (nonatomic) BOOL avcCHeaderParsed;
@property (nonatomic)dispatch_semaphore_t setupFfmpegStreamerSemaphore;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL withAudio;
@property (nonatomic, assign) BOOL withVideo;
@property (nonatomic, strong) NSString *relayServerIp;
@end

@implementation Streamer
@synthesize cameraPosition = _cameraPosition;

#pragma mark - Class mehtods
+ (AVCaptureSession *)sharedAVCaptureSession {
    static dispatch_once_t once;
    
    static AVCaptureSession *sharedSession;
    dispatch_once(&once, ^{
        sharedSession = [[AVCaptureSession alloc] init];
    });
    return sharedSession;
}

- (id)initWithUrl:(NSString *)url withAudio:(BOOL)withAudio withVideo:(BOOL)withVideo relayServerIp:(NSString *)relayServerIp {
    if (self = [super init]) {
        _url = url;
        _withAudio = withAudio;
        _withVideo = withVideo;
        _relayServerIp = relayServerIp;
        _setupFfmpegStreamerSemaphore = dispatch_semaphore_create(0);
        _cameraPosition = CameraPosition_Front;

        [self _setupEncoders];
        [self _setupSession];
        [self _setupNotification];
    }
    return self;
}

- (void)dealloc {
    [self _releaseEncoders];
    [self _releaseSession];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

#pragma mark - Setup Notifications
- (void)_setupNotification {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Auto rotation
- (AVCaptureVideoOrientation)avOrientationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
            
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
            
        default:
            return AVCaptureVideoOrientationLandscapeLeft;
    }
}

- (void)orientationDidChange:(NSNotification *)note {
    // Rotate the captured video
    if (_videoConnection && [_videoConnection isVideoOrientationSupported]) {
        [_videoConnection setVideoOrientation:[self avOrientationForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]];
    }
    
    // Rotate the video preview
    if (_previewLayer && [_previewLayer connection] && [[_previewLayer connection] isVideoOrientationSupported]) {
        [[_previewLayer connection] setVideoOrientation:[self avOrientationForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]];
    }
}

#pragma mark - Setup Session
- (void)_releaseSession {
    DDLogDebug(@"_releaseSession begin")
    @synchronized(_session) {
        if (_session) {
            [_session stopRunning];
            
            [self _releaseAudioCapture];
            [self _releaseVideoCapture];

            _previewLayer = nil;
            _session = nil;
        }
    }
    DDLogDebug(@"_releaseSession end")
}

- (void)_setupSession {
    DDLogDebug(@"_setupSession begin")
    @synchronized(_session) {
        _session = [Streamer sharedAVCaptureSession];   // If repeatedly calling _setupSession and _releaseSession, sometimes it will hang inside [[AVCaptureSession alloc] init]
        
        if (_withVideo) {
            [self _setupVideoCapture];
            [self _setupVideoPreview];
        }
        if (_withAudio) {
            [self _setupAudioCapture];
        }
        
        // start capture and a preview layer
        [_session startRunning];
    }
    DDLogDebug(@"_setupSession end")
}

- (AVCaptureDevice *)_getCamera {
    AVCaptureDevicePosition position;
    if (_cameraPosition == CameraPosition_Front)
        position = AVCaptureDevicePositionFront;
    else if (_cameraPosition == CameraPosition_Back)
        position = AVCaptureDevicePositionBack;
    else
        position = AVCaptureDevicePositionUnspecified;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void)_setupVideoCapture {
    AVCaptureDevice *videoDevice = [self _getCamera];

    NSError *error = nil;
    _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (error) {
        NSLog(@"Error getting video input device: %@", error.description);
    }
    if ([_session canAddInput:_videoInput]) {
        [_session addInput:_videoInput];
    }
    
    // create an output for YUV output with self as delegate
    _videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
    NSDictionary *captureSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    _videoOutput.videoSettings = captureSettings;
    _videoOutput.alwaysDiscardsLateVideoFrames = YES;
    if ([_session canAddOutput:_videoOutput]) {
        [_session addOutput:_videoOutput];
    }
    _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([_videoConnection isVideoOrientationSupported])
        [_videoConnection setVideoOrientation:[self avOrientationForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]];
}

- (void)_releaseVideoCapture {
    [_session removeInput:_videoInput];
    [_session removeOutput:_videoOutput];
    _videoQueue = nil;
    _videoInput = nil;
    _videoOutput = nil;
}

- (void)_setupVideoPreview {
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    if ([_previewLayer connection] && [[_previewLayer connection] isVideoOrientationSupported])
        [[_previewLayer connection] setVideoOrientation:[self avOrientationForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation]];
}

- (void)_setupAudioCapture {
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"Error getting audio input device: %@", error.description);
    }
    if ([_session canAddInput:_audioInput]) {
        [_session addInput:_audioInput];
    }
    
    _audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [_audioOutput setSampleBufferDelegate:self queue:_audioQueue];
    if ([_session canAddOutput:_audioOutput]) {
        [_session addOutput:_audioOutput];
    }
    _audioConnection = [_audioOutput connectionWithMediaType:AVMediaTypeAudio];
}

- (void)_releaseAudioCapture {
    [_session removeInput:_audioInput];
    [_session removeOutput:_audioOutput];
    _audioQueue = nil;
    _audioInput = nil;
    _audioOutput = nil;
}

//- (AVCaptureDevice *)audioDevice
//{
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
//    if ([devices count] > 0)
//        return [devices objectAtIndex:0];
//    
//    return nil;
//}

#pragma mark - Setup Encoders
- (void)_setupEncoders {
    if (_withVideo) {
        _h264Encoder = [[KFH264Encoder alloc] initWithBitrate:kVideoBitrate width:kVideoWith height:kVideoHeight];
        _h264Encoder.delegate = self;
    }
    
    if (_withAudio) {
        if (kUseAudioHwEncode) {
            _audioEncoder = [[KFAACEncoder alloc] initWithBitrate:kAudioBitrate sampleRate:kAudioSampleRate channels:kAudioChannels];
            ((KFAACEncoder *)_audioEncoder).addADTSHeader = YES;
        }
        else
            _audioEncoder = [[NellymoserEncoder alloc] initWithBitrate:kAudioBitrate sampleRate:kAudioSampleRate channels:kAudioChannels];
        _audioEncoder.delegate = self;
        
    }
}

- (void)_releaseEncoders {
    if (_h264Encoder) {
        [_h264Encoder shutdown];
        _h264Encoder = nil;
    }
    _audioEncoder = nil;
}

#pragma mark - AVCaptureOutputDelegate method
- (void)_applyMicrophoneMute:(CMSampleBufferRef)sampleBuffer {
    char *pcmBuffer;
    size_t pcmBufferSize;
    
    CFRetain(sampleBuffer);
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    CFRetain(blockBuffer);
    if (CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &pcmBufferSize, &pcmBuffer) != kCMBlockBufferNoErr) {
        return;
    }
    
    memset(pcmBuffer, 0, pcmBufferSize);
    
    CFRelease(sampleBuffer);
    CFRelease(blockBuffer);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // Encode the first sample to get SPS and PPS data for ffmpeg h264 configuration
    if (_h264Encoder && !_avcCHeaderParsed && connection == _videoConnection) {
        [_h264Encoder encodeSampleBuffer:sampleBuffer];
        _avcCHeaderParsed = YES;
    }
    
    if (!self.isStreaming) {
        return;
    }
    
    // Pass frame to encoders
    if (_h264Encoder && connection == _videoConnection) {
        [_h264Encoder encodeSampleBuffer:sampleBuffer];
    } else if (_audioEncoder && connection == _audioConnection) {
        if (self.microphoneMute)
            [self _applyMicrophoneMute:sampleBuffer];
        [_audioEncoder encodeSampleBuffer:sampleBuffer];
    }
}

#pragma mark - KFEncoderDelegate method
- (void)encoder:(KFEncoder*)encoder videoSpsAndPpsData:(NSData *)videoSpsAndPpsData {
    [self _setupFfmpegStreamer:videoSpsAndPpsData];
    dispatch_semaphore_signal(_setupFfmpegStreamerSemaphore);
}

- (void)encoder:(KFEncoder*)encoder encodedFrame:(KFFrame *)frame {
    if (encoder == _h264Encoder && _cameraPosition != CameraPosition_None) {
        KFVideoFrame *videoFrame = (KFVideoFrame*)frame;
        [_ffmpegStreamer processEncodedData:videoFrame.data presentationTimestamp:videoFrame.pts streamIndex:_ffmpegStreamer.videoStreamIndex isKeyFrame:videoFrame.isKeyFrame];
    } else if (encoder == _audioEncoder) {
        [_ffmpegStreamer processEncodedData:frame.data presentationTimestamp:frame.pts streamIndex:_ffmpegStreamer.audioStreamIndex isKeyFrame:NO];
    }
}

#pragma mark - Streamer operation

- (NSData *)_generateAudioExtraData {
    unsigned char audioSpecificConfig[2];
    
    // Generate AAC specific info (http://wiki.multimedia.cx/index.php?title=Understanding_AAC, http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio)
    // AudioSpecificInfo follows
    // oooo offf fccc c000
    // o - audioObjectType
    // f - samplingFreqIndex
    // c - channelConfig
    
    const NSArray *kSamplingFreqIndex = @[@(96000), @(88200), @(64000), @(48000), @(44100), @(32000), @(24000), @(22050), @(16000), @(12000), @(11025), @(8000), @(7350)];
    const NSArray *kChannelConfig = @[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(8)];
    
    NSUInteger audioObjectType = 2;    // AAC LC (Low Complexity)
    NSUInteger samplingFreqIndex = [kSamplingFreqIndex indexOfObject:@(kAudioSampleRate)];
    NSUInteger channelConfig = [kChannelConfig indexOfObject:@(kAudioChannels)];
    
    audioSpecificConfig[0] = ((audioObjectType << 3) & 0xF8) | ((samplingFreqIndex >> 1) & 0x07);
    audioSpecificConfig[1] = ((samplingFreqIndex << 7) & 0x80) | ((channelConfig << 3) & 0x78);
    
    return [NSData dataWithBytes:audioSpecificConfig length:2];
}

- (void)_setupFfmpegStreamer:(NSData *)videoSpsAndPpsData {
    _ffmpegStreamer = [[FfmpegStreamer alloc] initWithUrl:_url relayServerIp:_relayServerIp];
    
    if (_withVideo)
        [_ffmpegStreamer addVideoStreamWithWidth:kVideoWith height:kVideoHeight bitrate:kVideoBitrate extradata:videoSpsAndPpsData];
    
    if (_withAudio) {
        if (kUseAudioHwEncode)
            [_ffmpegStreamer addAudioStreamWithAudioFormat:AudioFormat_AAC sampleRate:kAudioSampleRate bitrate:kAudioBitrate extradata:[self _generateAudioExtraData]];
        else
            [_ffmpegStreamer addAudioStreamWithAudioFormat:AudioFormat_Nellymoser sampleRate:kAudioSampleRate bitrate:kAudioBitrate extradata:nil];
    }
}

- (BOOL)startStreaming {
    DDLogDebug(@"startStreaming begin");
    
    if (_withVideo) {
        // Wait for FfmpegStreamer being set up
        dispatch_semaphore_wait(_setupFfmpegStreamerSemaphore, DISPATCH_TIME_FOREVER);
    } else {
        [self _setupFfmpegStreamer:nil];
    }
    
    NSError *error = nil;
    if ([_ffmpegStreamer prepareForStreaming:&error]) {
        self.isStreaming = YES;
    }
    
    DDLogDebug(@"startStreaming end, error = %@", error);
    return self.isStreaming;
}

- (BOOL)stopStreaming {
    DDLogDebug(@"stopStreaming begin");
    
    @synchronized(_session) {
        [_session stopRunning];
    }
    
    NSError *error = nil;
    if (self.isStreaming) {
        [_ffmpegStreamer finishStreaming:&error];
        self.isStreaming = NO;
    }
    
    DDLogDebug(@"stopStreaming end");
    return !self.isStreaming;
}

- (void)setCameraPosition:(CameraPosition)position {
    if (_cameraPosition != position) {
        _cameraPosition = position;
        
        [self _releaseVideoCapture];
        
        if (_cameraPosition != CameraPosition_None)
            [self _setupVideoCapture];
    }
}

#pragma mark - Microphone Control
- (void)setMicrophoneGain:(float)gain {
    DDLogDebug(@"setMicGain: %f", gain);
    BOOL success = NO;
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (audioSession.isInputGainSettable) {
        success = [audioSession setInputGain:gain error:&error];
    }
}

- (float)microphoneGain {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    DDLogDebug(@"micGain: %f", audioSession.inputGain);
    return audioSession.inputGain;
}

@end