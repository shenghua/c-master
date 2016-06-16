//
//  NSMutableArray+TM.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/19/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import "NSMutableArray+TM.h"

@implementation NSMutableArray (TM)
- (id) dequeue {
    if ([self count] == 0) return nil;
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) enqueue:(id)anObject {
    [self addObject:anObject];
}
@end