//
//  WbRectangle.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/22.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "WbRectangle.h"

@interface WbRectangle()
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int objId;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int lineSize;
@property (nonatomic, assign) int lineColor;
@property (nonatomic, assign) int fillColor;
@property (nonatomic, weak) WbRectangle *weakSelf;
@end

@implementation WbRectangle

- (instancetype)initWithWo:(SessionWhiteboardObject *)wo {
    if (self = [super initWithWo:wo]) {
        _weakSelf = self;
        [self update:wo];
    }
    return self;
}

- (void)update:(SessionWhiteboardObject *)wo {
    [wo.properties enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        switch ([(NSNumber *)key intValue]) {
            case 0:
                _x = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 1:
                _y = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 2:
                _objId = [(NSNumber *)object intValue];
                break;
                
            case 3:
                _width = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 4:
                _height = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 5:
                _lineSize = [(NSNumber *)object intValue] * self.scale;
                if (_lineSize == 0)
                    _lineSize = 1;
                break;
                
            case 6:
                _lineColor = [(NSNumber *)object intValue];
                break;
                
            case 7:
                _fillColor = [(NSNumber *)object intValue];
                break;
                
            default:
                break;
        }
    }];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        int x = (_width > 0) ? _x : (_x + _width);
        int y = (_height > 0) ? _y : (_y + _height);
        
        // Add additional space for _lineSize
        _weakSelf.frame = CGRectMake(x - _lineSize/2.0, y - _lineSize/2.0, abs(_width) + _lineSize, abs(_height) + _lineSize);
        [_weakSelf setNeedsDisplay];
    });
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect strokeRect = CGRectMake(_lineSize / 2.0, _lineSize / 2.0, abs(_width), abs(_height));
    
    // Build a Bezier path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:1];
    CGContextAddPath(context, path.CGPath);
    
    // Set line width
    path.lineWidth = _lineSize;
    
    // set fill color
    if (_fillColor > 0) {
        NSArray *rgb = [WbObject getRGB:_fillColor];
        [[UIColor colorWithRed:[rgb[0] floatValue] green:[rgb[1] floatValue] blue:[rgb[2] floatValue] alpha:1.0] setFill];
        [path fill];
    }
    
    // Set stroke color
    NSArray *rgb = [WbObject getRGB:_lineColor];
    [[UIColor colorWithRed:[rgb[0] floatValue] green:[rgb[1] floatValue] blue:[rgb[2] floatValue] alpha:1.0] setStroke];
    [path stroke];
}

@end