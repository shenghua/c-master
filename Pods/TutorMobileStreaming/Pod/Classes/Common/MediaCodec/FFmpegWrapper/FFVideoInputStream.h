//
//  FFVideoInputStream.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/30.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "FFInputStream.h"

@interface FFVideoInputStream : FFInputStream
- (BOOL)setupVideoFrameFormat:(VideoFrameFormat)format;
@end
