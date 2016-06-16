//
//  WbFreehand.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/22.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "WbFreehand.h"

@interface WbFreehand()
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int objId;
@property (nonatomic, assign) int lineSize;
@property (nonatomic, assign) int lineColor;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, weak) WbFreehand *weakSelf;
@end

@implementation WbFreehand

- (instancetype)initWithWo:(SessionWhiteboardObject *)wo {
    if (self = [super initWithWo:wo]) {
        _weakSelf = self;
        _alpha = 1.0;
        _points = [NSMutableArray new];
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
                _lineSize = [(NSNumber *)object intValue] * self.scale;
                if (_lineSize == 0)
                    _lineSize = 1;
                break;
                
            case 4:
                _lineColor = [(NSNumber *)object intValue];
                break;
                
            case 5:
                [_points removeAllObjects];
                
                for (NSArray *points in object) {
                    int x = [(NSNumber *)points[0] intValue] * self.scale;
                    int y = [(NSNumber *)points[1] intValue] * self.scale;
                    
                    if (x > _width)
                        _width = x;
                    if (y > _height)
                        _height = y;
                    
                    [_points addObject:@[@(x), @(y)]];
                }
                
                break;
                
            default:
                break;
        }
    }];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        // Add additional space for _lineSize
        _weakSelf.frame = CGRectMake(_x - _lineSize, _y - _lineSize, _width + 2 * _lineSize, _height + 2 * _lineSize);
        [_weakSelf setNeedsDisplay];
    });
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Build a Bezier path
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    for (int i = 0; i < [_points count]; i++) {
        if (i == 0)
            [path moveToPoint:CGPointMake(_lineSize + [_points[i][0] intValue], _lineSize + [_points[i][1] intValue])];
        else
            [path addLineToPoint:CGPointMake(_lineSize + [_points[i][0] intValue], _lineSize + [_points[i][1] intValue])];
    }
    
    CGContextAddPath(context, path.CGPath);
    
    // Set line width
    path.lineWidth = _lineSize;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;
    
    // Set stroke color
    NSArray *rgb = [WbObject getRGB:_lineColor];
    [[UIColor colorWithRed:[rgb[0] floatValue] green:[rgb[1] floatValue] blue:[rgb[2] floatValue] alpha:_alpha] setStroke];
    [path stroke];
}

@end