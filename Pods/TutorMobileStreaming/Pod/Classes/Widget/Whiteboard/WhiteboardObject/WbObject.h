//
//  WbObject.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/18.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "librtmp/rtmp.h"
#import "SessionWhiteboardObject.h"

@interface WbObject : UIView
+ (NSArray *)getRGB:(int)rgb;

@property (nonatomic, assign) WhiteboardShape shape;
@property (nonatomic, assign) CGFloat scale;

- (instancetype)initWithWo:(SessionWhiteboardObject *)wo;
- (void)update:(SessionWhiteboardObject *)wo;
@end
