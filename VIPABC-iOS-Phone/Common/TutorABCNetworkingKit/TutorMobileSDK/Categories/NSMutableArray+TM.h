//
//  NSMutableArray+TM.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/19/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (TM)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end