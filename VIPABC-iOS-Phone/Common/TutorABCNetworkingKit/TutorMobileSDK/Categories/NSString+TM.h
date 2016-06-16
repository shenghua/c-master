//
//  NSString+TM.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 9/23/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNConstants.h"
#import "LocalizedString.h"

@interface NSString (TM)
+(NSString *) stringWithSessionType:(TMNClassSessionType)type;
+(NSString *) engStringWithSessionType:(TMNClassSessionType)type;
+(NSString *) stringWithSessionTypeNumber:(NSNumber *)number;

@end
