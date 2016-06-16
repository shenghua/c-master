//
//  SessionWhiteboardObject.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/20.
//
//

#import "SessionWhiteboardObject.h"

@implementation SessionWhiteboardObject
- (instancetype)init {
    self = [super init];
    if (self) {
        _properties = [NSMutableDictionary new];
    }
    return self;
}
@end
