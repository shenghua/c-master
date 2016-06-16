//
//  FrameType.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/24.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#ifndef TutorMobile_FrameType_h
#define TutorMobile_FrameType_h

#import <UIKit/UIKit.h>

typedef enum {
    FrameTypeAudio,
    FrameTypeVideo
} FrameType;

@interface Frame : NSObject
@property (readonly, nonatomic) FrameType type;
@property (readwrite, nonatomic) CGFloat position;
@property (readwrite, nonatomic) CGFloat duration;
- (void)free;
@end

@interface AudioFrame : Frame
@property (readwrite, nonatomic, strong) NSData *samples;
@end

typedef enum {
    VideoFrameFormatRGB,
    VideoFrameFormatYUV,
} VideoFrameFormat;

@interface VideoFrame : Frame
@property (readwrite, nonatomic) VideoFrameFormat format;
@property (readwrite, nonatomic) NSUInteger width;
@property (readwrite, nonatomic) NSUInteger height;
@end

@interface VideoFrameRGB : VideoFrame
@property (readwrite, nonatomic) NSUInteger linesize;
@property (readwrite, nonatomic, strong) NSData *rgb;
- (UIImage *) asImage;
@end

@interface VideoFrameYUV : VideoFrame
@property (readwrite, nonatomic, strong) NSData *luma;
@property (readwrite, nonatomic, strong) NSData *chromaB;
@property (readwrite, nonatomic, strong) NSData *chromaR;
@end

#endif
