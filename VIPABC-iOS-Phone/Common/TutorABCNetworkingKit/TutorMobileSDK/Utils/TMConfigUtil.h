//
//  TMConfigUtil.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/20/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMLesson.h"
#import "TMNConstants.h"

@interface TMConfigUtil : NSObject

+(instancetype)sharedUtil;
-(NSString *) strWithSessionType:(TMNClassSessionType) type;
-(NSString *) engStrWithSessionType:(TMNClassSessionType) type;
-(void) syncWithBlock:(void(^)(NSError *, id))block;
@end
