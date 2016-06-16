//
//  TMLessonUtil.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 9/23/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import "TMPlanLessonUtil.h"
#import "TMNNetworkLogicController.h"
#import "NSDate+TM.h"

#define kCachedTime 5000

@interface TMPlanLessonUtil ()

@property (nonatomic,assign) long long cachedTimestamp;
@property (nonatomic,strong) NSArray *cachedLessons;

@end

@implementation TMPlanLessonUtil

+ (instancetype)sharedUtil {
    static TMPlanLessonUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

-(void) syncLessonsWithResultBlock:(void(^)(NSError *error, NSArray *lessons))block{
    
    if([NSDate date].unixTimestamp-_cachedTimestamp > kCachedTime){
        
        
        _cachedTimestamp = [NSDate date].unixTimestamp;
        TMNNetworkLogicController *networkLogicController = [TMNNetworkLogicController sharedInstance];
        [networkLogicController getPlanWithBeginTime:[NSDate date].normalize.unixTimestamp endTime:[NSDate date].normalize.nextMonth.unixTimestamp successBlock:^(NSArray *responseArray) {
            
            _cachedLessons = responseArray;
            [[NSNotificationCenter defaultCenter] postNotificationName:kPlanedLessonsUpdateNotification object:self];
            if(block){
                block(nil, _cachedLessons);
            }

        } failedBlock:^(NSError *error, id responseObject) {
//            _cachedLessons = @[];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kPlanedLessonsUpdateNotification object:self];
            if(block){
                block(error, _cachedLessons);
            }
        }];
    }else{
        if(block){
            block(nil, _cachedLessons);;
        }
    }
}

-(void) forceSyncLessonsWithResultBlock:(void(^)(NSError *error, NSArray *lessons))block{

    _cachedTimestamp = [NSDate date].unixTimestamp;
    
    TMNNetworkLogicController *networkLogicController = [TMNNetworkLogicController sharedInstance];
    [networkLogicController getPlanWithBeginTime:[NSDate date].normalize.unixTimestamp endTime:[NSDate date].normalize.nextMonth.unixTimestamp successBlock:^(NSArray *responseArray) {
        
        _cachedLessons = responseArray;
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlanedLessonsUpdateNotification object:self];
        if(block){
            block(nil, _cachedLessons);
        }
        
    } failedBlock:^(NSError *error, id responseObject) {
        _cachedLessons = @[];
        if(block){
            block(error, _cachedLessons);
        }
    }];
}

-(NSArray *) lessonsCoverTime:(long long)begin andTime:(long long)end{
    NSMutableArray *array = [NSMutableArray array];
    
    for (TMLesson *lesson in _cachedLessons) {
        if((lesson.startTime>=begin && lesson.startTime<end) || (lesson.endTime>=begin && lesson.endTime<end)){
            [array addObject:lesson];
        }
    }
    
    return array;
}


-(NSArray *) lessonsStartBetweenTime:(long long)begin andTime:(long long)end{
    NSMutableArray *array = [NSMutableArray array];
    
    for (TMLesson *lesson in _cachedLessons) {
        if(lesson.startTime>=begin && lesson.startTime<end){
            [array addObject:lesson];
        }
    }
    
    return array;
}

-(NSArray *) lessonsBetweenTime:(long long)begin andTime:(long long)end amongLessons:(NSArray *)lessons{
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (TMLesson *lesson in lessons) {
        if(lesson.startTime>=begin && lesson.startTime<end){
            [array addObject:lesson];
        }
    }
    
    return array;
}

-(TMLesson *) isLesson:(TMLesson *)lesson conflictedWithLessons:(NSArray *)array{
    return nil;
}

-(NSArray *) cachedLessons{
    return _cachedLessons;
}

-(void) clean{
    _cachedLessons = @[];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlanedLessonsUpdateNotification object:self];
}

@end
