//
//  CircleProgressView.h
//  Pods
//
//  Created by TingYao Hsu on 2015/10/27.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol CircleProgressViewDelegate;

@interface CircleProgressView : UIView

@property (nonatomic, weak) NSObject<CircleProgressViewDelegate> *delegate;
@property (nonatomic, assign) float currentValue;
@property (nonatomic, assign) float newValue;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign, readonly) BOOL isAnimationInProgress;

- (void)setProgress:(NSNumber*)value;
@end

@protocol CircleProgressViewDelegate <NSObject>
- (void)didFinishAnimation:(CircleProgressView*)progressView;
@end