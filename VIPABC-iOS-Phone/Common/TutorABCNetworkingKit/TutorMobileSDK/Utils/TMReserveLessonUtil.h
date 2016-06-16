//
//  TMReserveLessonUtil.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/2/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMLesson.h"

#define kSelectedLessonsUpdateNotification @"onSelectedLessonsUpdate"

@interface TMReserveLessonUtil : NSObject

+(instancetype)sharedUtil;

-(void)reserveLesson:(TMLesson *)lesson;
-(void)cancelLesson:(TMLesson *)lesson;
-(void)clearLessons;
-(NSArray *)reservedLessons;
-(NSArray *)reservedLessonsOfType:(TMNClassSessionType) type;
-(NSArray *)lessonsConflictedWithLesson:(TMLesson *)lesson;
-(BOOL)reservedPowerSession;
-(BOOL)containLesson:(TMLesson *)lesson;
-(NSUInteger)count;
//-(void)checkConflict;
-(BOOL)containConflictLessons;

@end
