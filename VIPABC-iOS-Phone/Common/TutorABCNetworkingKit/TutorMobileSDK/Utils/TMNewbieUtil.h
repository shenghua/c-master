//
//  TMNewbieUtil.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/28/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMNewbieResponse;
@interface TMNewbieUtil : NSObject

+ (instancetype)sharedUtil;

-(void) checkNewbieWithBlock:(void(^)(NSError *error, TMNewbieResponse *newbieResponse))block;
-(void) clear;

@end
