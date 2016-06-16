//
//  WbObject.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/18.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "WbObject.h"
#import "LiveWhiteboard.h"

@implementation WbObject

- (instancetype)initWithWo:(SessionWhiteboardObject *)wo {
    if (self = [super initWithFrame:CGRectZero]) {
        [self setBackgroundColor:[UIColor clearColor]];
        _shape = wo.shape;
        
        [self _setupScale];
    }
    return self;
}

- (void)_setupScale {
    self.scale = [LiveWhiteboard getWhiteboardScale];
}

- (void)update:(SessionWhiteboardObject *)wo {
    wo = nil;
}

+ (NSArray *)getRGB:(int)color {
    CGFloat blue = (color & 0xFF) / 256.0;
    CGFloat green = ((color >> 8) & 0xFF) / 256.0;
    CGFloat red = ((color >> 16) & 0xFF) / 256.0;
    
    return @[@(red), @(green), @(blue)];
}
@end
