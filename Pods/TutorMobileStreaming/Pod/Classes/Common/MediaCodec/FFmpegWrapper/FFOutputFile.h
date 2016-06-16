//
//  FFOutputFile.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFFile.h"

#import "FFOutputStream.h"
#import "libavcodec/avcodec.h"
#import "FFBitstreamFilter.h"

@interface FFOutputFile : FFFile
@property (nonatomic) int64_t startTime;

- (void) addOutputStream:(FFOutputStream*)outputStream;

- (void) addBitstreamFilter:(FFBitstreamFilter*)bitstreamFilter;
- (void) removeBitstreamFilter:(FFBitstreamFilter*)bitstreamFilter;

- (BOOL) openFileForWritingWithError:(NSError**)error;
- (BOOL) writeHeaderWithError:(NSError**)error;
- (BOOL) writePacket:(AVPacket*)packet error:(NSError**)error;
- (BOOL) writeTrailerWithError:(NSError**)error;

@end