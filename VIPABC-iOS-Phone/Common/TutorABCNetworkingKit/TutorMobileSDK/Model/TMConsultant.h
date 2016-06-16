//
//  TMConsultant.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/1/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMConsultant : NSObject

@property (nonatomic, copy) NSString *status;

@property (nonatomic, assign) NSInteger consultantSn;

@property (nonatomic, copy) NSString *firstName;

@property (nonatomic, assign) float score;

@property (nonatomic, copy) NSString *birth;

@property (nonatomic, copy) NSString *level;

@property (nonatomic, copy) NSString *gender;

@property (nonatomic, copy) NSString *email;

@property (nonatomic, copy) NSString *consultantImg;

@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, assign) NSTimeInterval updatedTime;

@end
