//
//  RecordedWhiteboard.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/20.
//
//

#import "RecordedWhiteboard.h"
#import "WbObject.h"
#import "WbObjectFactory.h"

@implementation RecordedWhiteboard

#pragma mark - Public Methods
- (void)addObject:(SessionWhiteboardObject *)wo {
    if (!self.woDict[@(wo.objId)]) {
        WbObject *wbObject = [WbObjectFactory createRecordedWbObject:wo];
        
        if (wbObject) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.whiteboardView addSubview:wbObject];
            });
            self.woDict[@(wo.objId)] = wbObject;
        }
    }
    else
        [self updateObject:wo];
}

- (void)updateObject:(SessionWhiteboardObject *)wo {
    if (self.woDict[@(wo.objId)]) {
        WbObject *wbObject = self.woDict[@(wo.objId)];
        
        if (wo.shape == wbObject.shape)
            [wbObject update:wo];
        else {
            [self.woDict removeObjectForKey:@(wo.objId)];
            [self addObject:wo];
        }
    }
}
@end
