//
//  LiveWhiteboard.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/21.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "librtmp/rtmp.h"

@protocol WhiteboardDelegate <NSObject>
- (void)onWhiteboardSwipeLeft;
- (void)onWhiteboardSwipeRight;
@end

@interface LiveWhiteboard : UIView <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIView *whiteboardView;
@property (nonatomic) dispatch_queue_t taskQueue;
@property (nonatomic, strong, readonly) NSMutableDictionary *woDict;
@property (nonatomic, assign) int totalPages;
@property (nonatomic, assign) int pageIdx;

+ (CGFloat)getWhiteboardScale;
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<WhiteboardDelegate>)delegate;
- (void)resetWebPointer;
- (void)resetWebMouse;
- (void)webPointerChange:(CGPoint)point;
- (void)webMouseChange:(CGPoint)point;
- (void)addObject:(WhiteboardObject *)wbObject;
- (void)updateObject:(WhiteboardObject *)wbObject;
- (void)removeObject:(int)objId;
- (void)clearAllObjects;
@end
