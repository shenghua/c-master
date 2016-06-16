//
//  FFInputStream.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFStream.h"
#import "FFFrameType.h"
#import "FFInputFile.h"

@interface FFInputStream : FFStream
@property (nonatomic) CGFloat fps;
@property (nonatomic) CGFloat timebase;

// The following variables are protected
@property (nonatomic) AVCodecContext *codecCtx;

// Public methods
- (id)initWithInputFile:(FFInputFile*)newInputFile stream:(AVStream*)newStream;
- (BOOL)openStream;
- (void)closeStream;

// The following methods must be implemented by subclass
- (int)decodePacket:(AVPacket *)packet retFrame:(AVFrame *)frame gotFrame:(int *)gotframe;
- (Frame *)handleFrame:(AVFrame *)frame;
@end
