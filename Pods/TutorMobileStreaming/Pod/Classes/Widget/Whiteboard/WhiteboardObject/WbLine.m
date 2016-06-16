//
//  WbLine.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/21.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "WbLine.h"

@interface WbLine()
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int objId;
@property (nonatomic, assign) int diffX;
@property (nonatomic, assign) int diffY;
@property (nonatomic, assign) int lineSize;
@property (nonatomic, assign) int lineColor;
@property (nonatomic, assign) int type;
@property (nonatomic, weak) WbLine *weakSelf;
@end

@implementation WbLine

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
                _diffX = [(NSNumber *)object intValue] * self.scale;
                break;
                
            case 4:
                _diffY = [(NSNumber *)object intValue] * self.scale;
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
                _type = [(NSNumber *)object intValue];
                break;
                
            default:
                break;
        }
    }];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        int x = (_diffX > 0) ? _x : (_x + _diffX);
        int y = (_diffY > 0) ? _y : (_y + _diffY);

        // Add additional space for _lineSize
        _weakSelf.frame = CGRectMake(x - _lineSize, y - _lineSize, abs(_diffX) + 2 * _lineSize, abs(_diffY) + 2 * _lineSize);
        [_weakSelf setNeedsDisplay];
    });
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set line width
    CGContextSetLineWidth(context, _lineSize);

    // Set stroke color
    NSArray *rgb = [WbObject getRGB:_lineColor];
    CGFloat components[] = {[rgb[0] floatValue], [rgb[1] floatValue], [rgb[2] floatValue], 1.0};
    CGContextSetStrokeColor(context, components);
    
    int x = (_diffX > 0) ? _lineSize : abs(_diffX) + _lineSize;
    int y = (_diffY > 0) ? _lineSize : abs(_diffY) + _lineSize;
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x + _diffX, y + _diffY);
    CGContextStrokePath(context);
}

@end
