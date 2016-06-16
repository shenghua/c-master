//
//  FFInputFile.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFFile.h"
#import "FFFrameType.h"

@protocol FFInputFileDelegate <NSObject>
- (void)onTimeCodeEvent:(int)event;
- (void)onCuePointEvent:(NSString *)event;
- (void)onInsufficientBW;
@end

@interface FFInputFile : FFFile

- (BOOL)openFileForReading;
- (Frame *)getFrame;
- (BOOL)seek:(CGFloat)position; // millisecond
- (BOOL)pause;
- (BOOL)resume;

- (BOOL)setupVideoFrameFormat:(VideoFrameFormat)format;
- (CGFloat)getStreamDuration;   // millisecond
@end