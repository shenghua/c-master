//
//  LiveWhiteboard.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/21.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "LiveWhiteboard.h"
#import "WbObject.h"
#import "WbObjectFactory.h"
#import "TutorLog.h"

#define kMaxScale 1.5
#define kMinScale 0.7
#define kServerWhiteboardWidth  2732.0
#define kServerWhiteboardHeight 2048.0

#define kServerWhiteboardXOffeset 0.0
#define kServerWhiteboardYOffeset 0.0

#define kWebMouseShiftX 40.0
#define kWebMouseW 22.0
#define kWebMouseH 22.0
#define kWebPointerW 36.0
#define kWebPointerH 50.0

@interface LiveWhiteboard()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat whiteboardScale;
@property (nonatomic, weak) id<WhiteboardDelegate> delegate;
@property (nonatomic, assign) CGRect superViewFrame;

@property (nonatomic, strong) UIImageView *webPointer;
@property (nonatomic, strong) UIImageView *webMouse;
@end

@implementation LiveWhiteboard

+ (CGFloat)getWhiteboardScale {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 0.83;
    else
        return 0.5;
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<WhiteboardDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        _whiteboardScale = [LiveWhiteboard getWhiteboardScale];
        _superViewFrame = frame;
        _delegate = delegate;
        _woDict = [NSMutableDictionary new];
        _taskQueue = dispatch_queue_create("Whiteboard task queue", DISPATCH_QUEUE_SERIAL);
        
        // Setup gesture
        [self _setupGesture];
    }
    return self;
}

- (void)layoutSubviews {
    // Setup whiteboard view
    [self _setupWhiteboardView];
    
    // Setup webPointer and webMouse
    [self _setupDefaultImages];
}

- (void)_setupWhiteboardView {
    // Create whiteboard view
    CGSize serverWbSize = CGSizeMake(kServerWhiteboardWidth * _whiteboardScale, kServerWhiteboardHeight * _whiteboardScale);
    CGRect whiteboardFrame = CGRectMake(kServerWhiteboardXOffeset, kServerWhiteboardYOffeset, serverWbSize.width, serverWbSize.height);
    if (self.frame.size.width * self.frame.size.height > serverWbSize.width * serverWbSize.height)
        whiteboardFrame.size = self.frame.size;
    
    if (!_whiteboardView)
        _whiteboardView = [[UIView alloc] init];
    _whiteboardView.frame = whiteboardFrame;
    
    // Create scroll view
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView addSubview:_whiteboardView];
        [self addSubview:_scrollView];
    }
    _scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [_scrollView setContentSize:whiteboardFrame.size];
    _scrollView.clipsToBounds = NO;
    _scrollView.maximumZoomScale = kMaxScale;
    _scrollView.minimumZoomScale = kMinScale;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.delegate = self;
}

- (void)_setupDefaultImages {
    if (!_webMouse) {
        UIImage *imgWebMouse = [UIImage imageNamed:@"sessionroom_wb_hand"];
        
        _webMouse = [[UIImageView alloc] initWithImage:imgWebMouse];
        _webMouse.frame = CGRectMake(0, 0, kWebMouseW * _whiteboardScale, kWebMouseH * _whiteboardScale);
        _webMouse.hidden = YES;

        [_whiteboardView addSubview:_webMouse];
    }
    
    if (!_webPointer) {
        UIImage *imgWebPointer = [UIImage imageNamed:@"sessionroom_wb_pointer"];
        
        _webPointer = [[UIImageView alloc] initWithImage:imgWebPointer];
        _webPointer.frame = CGRectMake(0, 0, kWebPointerW * _whiteboardScale, kWebPointerH * _whiteboardScale);
        _webPointer.hidden = YES;
        
        [_whiteboardView addSubview:_webPointer];
    } 
}

- (void)_setupGesture {
//    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipePiece:)];
//    [swipeLeftRecognizer setDelegate:self];
//    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
//    [self addGestureRecognizer:swipeLeftRecognizer];
//    
//    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipePiece:)];
//    [swipeRightRecognizer setDelegate:self];
//    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
//    [self addGestureRecognizer:swipeRightRecognizer];

    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_resetPiece:)];
    [doubleTapRecognizer setDelegate:self];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapRecognizer];
}

#pragma mark - Public Methods
- (void)addObject:(WhiteboardObject *)wo {
    [self resetWebPointer];
    [self resetWebMouse];
    
    if (!_woDict[@(wo->objId)]) {
        WbObject *wbObject = [WbObjectFactory createLiveWbObject:wo];
        
        if (wbObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_whiteboardView addSubview:wbObject];
            });
            _woDict[@(wo->objId)] = wbObject;
        }
    }
    else
        [self updateObject:wo];
}

- (void)updateObject:(WhiteboardObject *)wo {
    [self resetWebPointer];
    [self resetWebMouse];
    
    if (_woDict[@(wo->objId)]) {
        WbObject *wbObject = _woDict[@(wo->objId)];
        wo->shape = wbObject.shape;
        SessionWhiteboardObject *sessionWbObject = [WbObjectFactory getRecordedWbObjectFromLiveWbObject:wo];
        [wbObject update:sessionWbObject];
        sessionWbObject = nil;
    }
}

- (void)removeObject:(int)objId {
    [self resetWebPointer];
    [self resetWebMouse];
    
    if (_woDict[@(objId)]) {
        WbObject *wbObject = _woDict[@(objId)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wbObject removeFromSuperview];
            [_woDict removeObjectForKey:@(objId)];
        });
    }
}

- (void)resetWebPointer {
    dispatch_async(dispatch_get_main_queue(), ^{
//        DDLogDebug(@"resetWebPointer");
        _webPointer.hidden = YES;
    });
}

- (void)resetWebMouse {
    dispatch_async(dispatch_get_main_queue(), ^{
//        DDLogDebug(@"resetWebMouse");
        _webMouse.hidden = YES;
    });
}

- (void)webPointerChange:(CGPoint)point {
    [self resetWebMouse];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"webPointerChange %f, %f", point.x * _whiteboardScale, point.y * _whiteboardScale);
        
        [_whiteboardView bringSubviewToFront:_webPointer];
        _webPointer.hidden = NO;
        
        _webPointer.frame = CGRectMake(point.x * _whiteboardScale,
                                       point.y * _whiteboardScale,
                                       _webPointer.frame.size.width,
                                       _webPointer.frame.size.height);
    });
}

- (void)webMouseChange:(CGPoint)point {
    [self resetWebPointer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"webMouseChange %f, %f", (point.x - kWebMouseShiftX) * _whiteboardScale, point.y * _whiteboardScale);
        
        [_whiteboardView bringSubviewToFront:_webMouse];
        _webMouse.hidden = NO;
        
        _webMouse.frame = CGRectMake((point.x - kWebMouseShiftX) * _whiteboardScale,
                                     point.y * _whiteboardScale,
                                     _webMouse.frame.size.width,
                                     _webMouse.frame.size.height);
    });
}

- (void)clearAllObjects {
    [self resetWebPointer];
    [self resetWebMouse];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        DDLogDebug(@"clearAllObjects");
        for (UIView *subview in _whiteboardView.subviews) {
            if (subview != _webMouse && subview != _webPointer)
                [subview removeFromSuperview];
        }
        
        [_woDict removeAllObjects];
    });
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _whiteboardView;
}

#pragma mark - Gesture Handler

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (CGRect)_zoomRectForScale:(float)scale withCenter:(CGPoint)center fromView:(UIView *)fromView {
    CGRect zoomRect;
    
    zoomRect.size.height = [_scrollView frame].size.height / scale;
    zoomRect.size.width  = [_scrollView frame].size.width  / scale;
    
    center = [_whiteboardView convertPoint:center fromView:fromView];
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

- (void)_resetPiece:(UIPanGestureRecognizer *)gestureRecognizer {
    if (_scrollView.zoomScale == 1.0) {
        CGRect zoomRect = [self _zoomRectForScale:kMaxScale
                                       withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]
                                         fromView:gestureRecognizer.view];
        [_scrollView zoomToRect:zoomRect animated:YES];
    }
    else {
        [_scrollView zoomToRect:CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height) animated:YES];
    }
}

- (void)_swipePiece:(UISwipeGestureRecognizer *)gestureRecognizer {
    // Swipe from right to left
    if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionLeft) {
        DDLogDebug(@"Swipe left");
        
        if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardSwipeLeft)])
            [_delegate onWhiteboardSwipeLeft];
        
    // Swipe from left to right
    } else {
        DDLogDebug(@"Swipe right");
        
        if (_delegate && [_delegate respondsToSelector:@selector(onWhiteboardSwipeRight)])
            [_delegate onWhiteboardSwipeRight];
    }
}
@end
