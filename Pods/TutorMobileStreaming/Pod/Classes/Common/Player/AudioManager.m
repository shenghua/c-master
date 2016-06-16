//
//  AudioManager.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/3.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

// Ref: https://developer.apple.com/library/ios/samplecode/MixerHost/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010210-Intro-DontLinkElementID_2

#import "AudioManager.h"
#import "TutorLog.h"
#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>

#define RETURN_IF_ERROR(status) if (status != noErr) return NO;

#define kNumOutputChannels 1
#define kSamplingRate 16000 //44100 22050 16000 11025
#define kNumBytesPerSample 4

#define MAX_FRAME_SIZE 4096
#define MAX_CHAN       2

static UInt32 kMixerBusCount = 1;    // Bus count for mixer unit input
static UInt32 kMixerInputBus = 0;    // Mixer unit bus 0 will take the sound

@interface AudioManager()
@property (nonatomic, readwrite) const UInt32  numOutputChannels;
@property (nonatomic, readwrite) const Float64 samplingRate;
@property (nonatomic, readwrite) const UInt32  numBytesPerSample;
@property (nonatomic) AUGraph audioGraph;
@property (nonatomic) AudioUnit ioUnit;
@property (nonatomic) AudioUnit mixerUnit;
@property (nonatomic) float *outData;
@end

@implementation AudioManager

- (instancetype)init {
    if (self = [super init]) {
        self.numOutputChannels = kNumOutputChannels;
        self.samplingRate = kSamplingRate;
        self.numBytesPerSample = kNumBytesPerSample;

        _outData = (float *)calloc(MAX_FRAME_SIZE * MAX_CHAN, kNumBytesPerSample);
        
        if (![self _createAudioGraph])
            self = nil;
    }
    return self;
}

- (void)dealloc {
    if (_outData) {
        free(_outData);
        _outData = NULL;
    }
}

/**
 *  This callback is called when the mixerUnit needs new data to play.
 */
static OSStatus inputRenderCallback(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData) {
    // Notes: mNumberBuffers depends on self.numOutputChannels
    @autoreleasepool {
        AudioManager *audioManager = (__bridge AudioManager *)inRefCon;
        [audioManager.delegate audioCallbackFillData:audioManager.outData numFrames:inNumberFrames];
        
        // Put the data into the output buffer
        for (int i = 0; i < ioData->mNumberBuffers; i++)
            memcpy(ioData->mBuffers[i].mData, audioManager.outData, ioData->mBuffers[i].mDataByteSize);
    }

    return noErr;
}

- (BOOL)_createAudioGraph {
    OSStatus result = noErr;
    
    // Create a new audio graph
    result = NewAUGraph(&_audioGraph);
    RETURN_IF_ERROR(result);

    // Specify the audio unit component descriptions for the audio units to be added to the graph.
    // I/O unit
    AudioComponentDescription ioUnitDescription;
    ioUnitDescription.componentType          = kAudioUnitType_Output;
    ioUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    ioUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags         = 0;
    ioUnitDescription.componentFlagsMask     = 0;
    
    // Multichannel mixer unit
    AudioComponentDescription mixerUnitDescription;
    mixerUnitDescription.componentType          = kAudioUnitType_Mixer;
    mixerUnitDescription.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    mixerUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    mixerUnitDescription.componentFlags         = 0;
    mixerUnitDescription.componentFlagsMask     = 0;
    
    // Add nodes to the audio graph
    AUNode   ioNode;         // Node for I/O unit
    AUNode   mixerNode;      // Node for Multichannel Mixer unit
    
    // Add the nodes to the audio graph
    result =  AUGraphAddNode(_audioGraph, &ioUnitDescription, &ioNode);
    RETURN_IF_ERROR(result);
    
    
    result = AUGraphAddNode(_audioGraph, &mixerUnitDescription, &mixerNode);
    RETURN_IF_ERROR(result);
    
    
    // Open the audio graph
    // Following this call, the audio units are instantiated but not initialized
    // (no resource allocation occurs and the audio units are not in a state to process audio)
    result = AUGraphOpen(_audioGraph);
    RETURN_IF_ERROR(result);
    
    // Obtain the io/mixer unit instance from its corresponding node
    result = AUGraphNodeInfo(_audioGraph, ioNode, NULL, &_ioUnit);
    RETURN_IF_ERROR(result);
    
    result = AUGraphNodeInfo(_audioGraph, mixerNode, NULL, &_mixerUnit);
    RETURN_IF_ERROR(result);
    
    // Multichannel Mixer unit Setup
    result = AudioUnitSetProperty (_mixerUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &kMixerBusCount,
                                   sizeof(kMixerBusCount));
    RETURN_IF_ERROR(result);
    
    // Increase the maximum frames per slice allows the mixer unit to accommodate the
    //    larger slice size used when the screen is locked.
    UInt32 maximumFramesPerSlice = 4096;
    result = AudioUnitSetProperty(_mixerUnit,
                                  kAudioUnitProperty_MaximumFramesPerSlice,
                                  kAudioUnitScope_Global,
                                  0,
                                  &maximumFramesPerSlice,
                                  sizeof(maximumFramesPerSlice));
    RETURN_IF_ERROR(result);
    
    // Attach the input render callback and context to each input bus
    for (UInt16 busNumber = 0; busNumber < kMixerBusCount; ++busNumber) {
        
        // Setup the struture that contains the input render callback
        AURenderCallbackStruct inputCallbackStruct;
        inputCallbackStruct.inputProc = &inputRenderCallback;
        inputCallbackStruct.inputProcRefCon = (__bridge void *)self;

        // Set a callback for the specified node's specified input
        result = AUGraphSetNodeInputCallback(_audioGraph,
                                             mixerNode,
                                             busNumber,
                                             &inputCallbackStruct);
        RETURN_IF_ERROR(result);
    }
    
    // Setup stream format for mixer unit
    result = [self _setupMixerStreamFormat:self.numOutputChannels samplingRate:self.samplingRate];
    RETURN_IF_ERROR(result);
    
    // Connect the nodes of the audio graph
    result = AUGraphConnectNodeInput(_audioGraph,
                                     mixerNode,         // source node
                                     0,                 // source node output bus number
                                     ioNode,            // destination node
                                     0);                // desintation node input bus number
    RETURN_IF_ERROR(result);
    
    // Show the state of the audio graph
    CAShow (_audioGraph);

    // Initialize the audio graph, configure audio data stream formats for
    //  each input and output, and validate the connections between audio units.
    result = AUGraphInitialize(_audioGraph);
    RETURN_IF_ERROR(result);
    
    return YES;
}

- (OSStatus)_setupMixerStreamFormat:(UInt32)numOutputChannels samplingRate:(Float64)samplingRate {
    OSStatus result = noErr;
    
    // Describe mixer unit format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= samplingRate;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;                                // The number of frames in a packet of audio data. For uncompressed audio, the value is 1.
    audioFormat.mChannelsPerFrame	= numOutputChannels;                // The number of channels in each frame of data.
    audioFormat.mBitsPerChannel		= self.numBytesPerSample * 8;       // The number of bits of sample data for each channel in a frame of data.
    audioFormat.mBytesPerFrame		= audioFormat.mChannelsPerFrame *   // The number of bytes from the start of one frame to the start of the next frame in an audio buffer.
    self.numBytesPerSample;
    audioFormat.mBytesPerPacket		= audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
    
    // Apply mixer unit format
    result = AudioUnitSetProperty(_mixerUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kMixerInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    // kAudioUnitErr_FormatNotSupported (-10868)
    return result;
}

#pragma mark - Public methods

- (void)start {
    @synchronized(self) {
        if (_audioGraph)
            AUGraphStart(_audioGraph);
    }
}

- (void)stop {
    @synchronized(self) {
        if (_audioGraph) {
            Boolean isRunning = false;
            OSStatus result = AUGraphIsRunning(_audioGraph, &isRunning);
            
            if (result == noErr && isRunning) {
                AUGraphStop(_audioGraph);
            }
        }
    }
}

- (void)close {
    @synchronized(self) {
        if (_audioGraph) {
            AUGraphUninitialize(_audioGraph);
            DisposeAUGraph(_audioGraph);
            _audioGraph = nil;
        }
    }
}

- (BOOL)updateAudioParams:(UInt32)numOutputChannels samplingRate:(Float64)samplingRate {
    DDLogDebug(@"updateAudioParams numOutputChannels: %d, samplingRate: %f", numOutputChannels, samplingRate);

    if ([self _setupMixerStreamFormat:numOutputChannels samplingRate:samplingRate] == noErr) {
        self.numOutputChannels = numOutputChannels;
        self.samplingRate = samplingRate;
        
        CAShow (_audioGraph);
        return YES;
    }
    return NO;
}

- (float)volumeFactor {
    AudioUnitParameterValue volFactor = 0;
    
    if (_mixerUnit) {
        OSStatus result = AudioUnitGetParameter(_mixerUnit,
                                                kMultiChannelMixerParam_Volume,
                                                kAudioUnitScope_Output,
                                                kMixerInputBus,
                                                &volFactor);
        DDLogDebug(@"volumeFactor: %f, result: %d", volFactor, result);
    }
    
    return volFactor;
}

- (void)setVolumeFactor:(float)volumeFactor {
    if (_mixerUnit) {
        OSStatus result = AudioUnitSetParameter(_mixerUnit,
                                                kMultiChannelMixerParam_Volume,
                                                kAudioUnitScope_Output,
                                                kMixerInputBus,
                                                volumeFactor,
                                                0);
        DDLogDebug(@"setVolumeFactor: %f, result: %d", volumeFactor, result);
    }
}

@end
