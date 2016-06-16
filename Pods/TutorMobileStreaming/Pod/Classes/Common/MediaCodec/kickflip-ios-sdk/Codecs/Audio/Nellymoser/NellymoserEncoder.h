//
//  NellymoserEncoder.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/25.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "KFAudioEncoder.h"

@interface NellymoserEncoder : KFAudioEncoder

@property (nonatomic) dispatch_queue_t encoderQueue;

@end
