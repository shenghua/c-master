//
//  FFFrameType.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/30.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FFFrameType.h"

@implementation Frame
- (void)free {
}
@end

@implementation AudioFrame
- (FrameType)type {
    return FrameTypeAudio;
}
- (void)free {
    [super free];
    self.samples = nil;
}
@end

@implementation VideoFrame
- (FrameType)type {
    return FrameTypeVideo;
}
@end

@implementation VideoFrameRGB
- (VideoFrameFormat)format {
    return VideoFrameFormatRGB;
}

- (UIImage *)asImage
{
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(_rgb));
    if (provider) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace) {
            CGImageRef imageRef = CGImageCreate(self.width,
                                                self.height,
                                                8,
                                                24,
                                                self.linesize,
                                                colorSpace,
                                                kCGBitmapByteOrderDefault,
                                                provider,
                                                NULL,
                                                YES, // NO
                                                kCGRenderingIntentDefault);
            
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            CGColorSpaceRelease(colorSpace);
        }
        CGDataProviderRelease(provider);
    }
    
    return image;
}

- (void)free {
    [super free];
    self.rgb = nil;
}
@end

@implementation VideoFrameYUV
- (VideoFrameFormat)format {
    return VideoFrameFormatYUV;
}

- (void)free {
    [super free];
    self.luma = nil;
    self.chromaB = nil;
    self.chromaR = nil;
}
@end