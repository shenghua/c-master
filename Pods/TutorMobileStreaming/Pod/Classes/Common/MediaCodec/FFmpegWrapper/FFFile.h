//
//  FFFile.h
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "avformat.h"

@interface FFFile : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, assign) AVFormatContext *formatContext;
@property (nonatomic) NSMutableArray *streams;

- (id) initWithPath:(NSString*)path options:(NSDictionary*)options;
@end