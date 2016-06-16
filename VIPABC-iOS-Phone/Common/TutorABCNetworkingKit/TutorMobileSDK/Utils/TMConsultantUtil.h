//
//  TMConsultantUtil.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/14/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMConsultant;

@interface TMConsultantUtil : NSObject

+ (instancetype)sharedUtil;

-(TMConsultant *) getConsultantWithSn:(NSString *)sn andBlock:(void(^)(NSError *error, TMConsultant *consultant, BOOL alreadyReturn))block;

@end
