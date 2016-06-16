//
//  TMLessonUtil.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 9/23/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMLesson.h"

#define kPlanedLessonsUpdateNotification @"onPlanedLessonsUpdate"

@interface TMPlanLessonUtil : NSObject



+(instancetype)sharedUtil;
-(void) syncLessonsWithResultBlock:(void(^)(NSError *error, NSArray *lessons))block;
-(void) forceSyncLessonsWithResultBlock:(void(^)(NSError *error, NSArray *lessons))block;
-(NSArray *) lessonsBetweenTime:(long long)begin andTime:(long long)end amongLessons:(NSArray *)lessons;


-(NSArray *) lessonsCoverTime:(long long)begin andTime:(long long)end;
-(NSArray *) lessonsStartBetweenTime:(long long)begin andTime:(long long)end;
-(TMLesson *) isLesson:(TMLesson *)lesson conflictedWithLessons:(NSArray *)array;
-(NSArray *) cachedLessons;

-(void) clean;


@end
