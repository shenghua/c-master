//
//  CircleProgressView.m
//  Pods
//
//  Created by TingYao Hsu on 2015/10/27.
//
//

#import "CircleProgressView.h"

@interface CircleProgressView()
@property (nonatomic, assign, readwrite) BOOL isAnimationInProgress;
@property (nonatomic, strong) UIBezierPath *bgCirclePath;
@property (nonatomic, strong) CAShapeLayer *bgCircle;
@property (nonatomic, strong) CAGradientLayer *bg;
@end

@implementation CircleProgressView
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        float radius = self.frame.size.width/2 - 5.0;
        
        _bgCircle = [CAShapeLayer layer];
        _bgCirclePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2,self.frame.size.height/2)
                                                              radius:radius startAngle:-M_PI_2 endAngle:M_PI clockwise:YES];
        _bgCirclePath.usesEvenOddFillRule = YES;
        _bgCircle.path = _bgCirclePath.CGPath;
        _bgCircle.lineWidth = 3; // TODO: make it configurable
        _bgCircle.strokeColor = [UIColor blackColor].CGColor; // TODO: Make it configurable
        _bgCircle.fillColor = [UIColor clearColor].CGColor; // TODO: Make it configurable
        
        
        // Draw gradient layer
        _bg = [CAGradientLayer layer];
        _bg.anchorPoint = CGPointMake(0,0);
        _bg.frame = self.frame;
        _bg.position = CGPointMake(0,0);
        _bg.colors = @[(__bridge id)[UIColor colorWithRed:221/255.f green:70/255.f blue:72/255.f alpha:1.f].CGColor,
                       (__bridge id)[UIColor colorWithRed:193/255.f green:63/255.f blue:65/255.f alpha:1.f].CGColor];
        _bg.startPoint = CGPointMake(0.5,0);
        _bg.endPoint = CGPointMake(0.5,1);
        [self.layer addSublayer:_bg];
        
        // Make a circular shape
        _bg.mask = _bgCircle;
        
    }
    return self;
}

- (void)setProgress:(NSNumber*)value {
    
    float newValue = [value floatValue];
    
    if (newValue > 1.0) newValue = 1.0;
    if (newValue < 0) newValue = 0;
    
    if (self.isAnimationInProgress) {
        self.newValue = newValue;
        return;
    }
    
    [self updateView:newValue];
    
    self.currentValue = newValue;
}


- (void)updateView:(float)newValue {
    
    float radius = self.frame.size.width/2 - 5.0;
    float startAngle = -M_PI_2;
    float endAngle = -M_PI_2 + 2*M_PI*(1-newValue);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2,self.frame.size.height/2)
                                   radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    _bgCircle.path = path.CGPath;
    self.isAnimationInProgress = NO;
}

@end
