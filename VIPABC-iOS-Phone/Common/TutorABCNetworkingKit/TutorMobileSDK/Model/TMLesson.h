//
//  TMLessons.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 9/18/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNConstants.h"

typedef enum : NSUInteger {
    TMLessonStyle_Normal,
    TMLessonStyle_Normal_Selected,
    TMLessonStyle_Normal_Not_Cancelable,
    TMLessonStyle_Normal_Not_Cancelable_Selected,
    TMLessonStyle_Already_Reserved_Cancelable,
    TMLessonStyle_Already_Reserved_Not_Cancelable,
    TMLessonStyle_Already_Reserved_Cancelable_2,
    TMLessonStyle_Already_Reserved_Not_Cancelable_2,
    TMLessonStyle_Over_Reserve_Time,
    TMLessonStyle_Not_Opend
    
} TMLessonStyle;

typedef enum : NSInteger {
    TMLessonSessionStatus_Over = 0 ,
    TMLessonSessionStatus_Can_Reserve = 1,
    TMLessonSessionStatus_Can_Reserve_Cannot_Cancel = 7,
    TMLessonSessionStatus_Already_Reserved_Can_Cancel = 2,
    TMLessonSessionStatus_Already_Reserved_Cannot_Cancel = 3,
    TMLessonSessionStatus_Already_Reserved_Can_Cancel_2 = 4,
    TMLessonSessionStatus_Already_Reserved_Cannot_Cancel_2 = 8,
    TMLessonSessionStatus_Not_Open = 5,
    TMLessonSessionStatus_Over_Reverve_Time = 6,
} TMLessonSessionStatus;

typedef enum : NSInteger {
    TMLessonPlanStatus_Cannot_Review = 0,
    TMLessonPlanStatus_Can_Review = 1,
    TMLessonPlanStatus_Can_Enter = 2
    
} TMLessonPlanStatus;

@class Classdetail,TMPlanDummyLesson;
@interface TMLesson : NSObject

@property (nonatomic, assign) TMNClassSessionType sessionType;

@property (nonatomic, assign) NSTimeInterval endTime;

@property (nonatomic, copy) NSString *usePoints;

@property (nonatomic, copy) NSString *otherAttend;

@property (nonatomic, copy) NSString *startTime_human;

@property (nonatomic, assign) TMLessonSessionStatus sessionStatus;

@property (nonatomic, assign) TMLessonPlanStatus status;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, strong) Classdetail *classDetail;

/**
 *  from dummy plan lesson
 */
@property (nonatomic, assign) NSInteger attendSn;

/**
 *  from dummy plan lesson
 */
@property (nonatomic, copy) NSString *sessionSn;

/**
 *  from dummy plan lesson
 */
@property (nonatomic, assign) BOOL canCancel;

/**
 *  for ordering
 */
@property (nonatomic, assign) NSInteger order;

/**
 *  for conflict pink background
 */
@property (nonatomic, assign) BOOL isConflict;

-(NSString *)hashString;

-(NSString *)cancelString;

-(NSString *)fullString;

-(BOOL) isConflictWithLesson:(TMLesson *)lesson;

+(TMLesson *) lessonWithPlanDummyLesson:(TMPlanDummyLesson *) lesson;

@end

@interface Classdetail : NSObject

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *materialImage;

@property (nonatomic, copy) NSString *titleEN;

@property (nonatomic, assign) NSInteger lobbySn;

@property (nonatomic, copy) NSString *consultant;

@property (nonatomic, assign) NSInteger materialSn;

@property (nonatomic, assign) NSInteger lobbyType;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *level;

@property (nonatomic, copy) NSString *consultantImage;

@property (nonatomic, assign) NSInteger consultantSn;

@property (nonatomic, assign) BOOL isClientLevelMatched;

@end


@interface TMPlanDummyLesson : NSObject

@property (nonatomic, assign) TMNClassSessionType sessionType;

@property (nonatomic, assign) TMLessonPlanStatus status;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, assign) NSTimeInterval endTime;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *materialSn;

@property (nonatomic, copy) NSString *consultantSn;

@property (nonatomic, copy) NSString *usePoints;

@property (nonatomic, copy) NSString *sessionSn;

@property (nonatomic, copy) NSString *lobbySn;

@property (nonatomic, copy) NSString *titleEN;

@property (nonatomic, assign) BOOL canCancel;

@property (nonatomic, assign) NSInteger attendSn;

@end

