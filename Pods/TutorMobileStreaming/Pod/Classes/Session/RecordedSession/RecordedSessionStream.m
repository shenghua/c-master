//
//  RecordedSessionStream.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/20.
//
//

#import "RecordedSessionStream.h"

@implementation RecordedSessionStream
- (instancetype)init {
    self = [super init];
    if (self) {
        _enterLeaveTimeList = [NSMutableArray new];
    }
    return self;
}
@end
