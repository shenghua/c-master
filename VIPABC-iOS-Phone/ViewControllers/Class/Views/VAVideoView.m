//
//  VAVideoView.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/19.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAVideoView.h"

@interface VAVideoView ()

@property (nonatomic, assign) CGPoint beginPoint;

@end

@implementation VAVideoView

@synthesize beginPoint, moveable;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    
    if (!self)
        return nil;
    
    moveable = NO;
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!moveable)
        return;
    
    UITouch *touch = [touches anyObject];
    
    beginPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!moveable)
        return;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint nowPoint = [touch locationInView:self];
    
    float offsetX = nowPoint.x - beginPoint.x;
    float offsetY = nowPoint.y - beginPoint.y;
    
    self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
    
    self.movedX = self.frame.origin.x;
    self.movedY = self.frame.origin.y;
}

@end
