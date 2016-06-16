//
//  FFDataInputStream.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/30.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "FFDataInputStream.h"
#import "libavformat/avformat.h"

@implementation FFDataInputStream
- (BOOL)openStream {
    return YES;
}

- (void)closeStream {

}

- (int)decodePacket:(AVPacket *)packet retFrame:(AVFrame *)frame gotFrame:(int *)gotframe {
    return -1;
}

- (Frame *)handleFrame:(AVFrame *)avFrame {
    return nil;
}
@end
