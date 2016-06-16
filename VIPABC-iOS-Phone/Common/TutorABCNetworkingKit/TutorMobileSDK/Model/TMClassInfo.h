//
//  TMClassInfo.h
//  TutorMobile
//
//  Created by AbbyHsu on 2015/10/2.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMClassInfo : NSObject

@property (nonatomic, copy) NSString *sessionBeginDate;

@property (nonatomic, copy) NSString *materialImg;

@property (nonatomic, copy) NSString *materialSn;

@property (nonatomic, copy) NSString *maxCount;

@property (nonatomic, copy) NSString *sessionTypeTW;

@property (nonatomic, copy) NSString *usedPoint;

@property (nonatomic, copy) NSString *consultantImg;

@property (nonatomic, copy) NSString *lobbySn;

@property (nonatomic, copy) NSString *sessionIntroductionTW;

@property (nonatomic, copy) NSString *sessionLevel;

@property (nonatomic, copy) NSString *sessionEndDate;

@property (nonatomic, copy) NSString *sessionTypeCN;

@property (nonatomic, copy) NSString *sessionMinLevel;

@property (nonatomic, copy) NSString *sessionMaxLevel;

@property (nonatomic, assign)  BOOL followConsultant;

@property (nonatomic, assign) long long sessionEndDateTS;

@property (nonatomic, assign) int attend;

@property (nonatomic, copy) NSString *checkInStatus;

@property (nonatomic, copy) NSString *sessionPeriod;

@property (nonatomic, copy) NSString *sessionTypeEN;

@property (nonatomic, copy) NSString *sessionTitleEN;

@property (nonatomic, copy) NSString *noCancel;

@property (nonatomic, copy) NSString *sessionTitleCN;

@property (nonatomic, assign) BOOL canCancel;

@property (nonatomic, assign) NSInteger sessionTypeSn;

@property (nonatomic, copy) NSString *sessionIntroductionCN;

@property (nonatomic, copy) NSString *noOrder;

@property (nonatomic, assign) long long sessionBeginDateTS;

@property (nonatomic, copy) NSString *sessionSn;

@property (nonatomic, copy) NSString *consultantSn;

@property (nonatomic, copy) NSString *sessionTitleTW;

//for cache
@property (nonatomic, assign) NSTimeInterval updatedTime;

@end
