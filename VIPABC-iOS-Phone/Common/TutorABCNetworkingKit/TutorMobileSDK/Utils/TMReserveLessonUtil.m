//
//  TMReserveLessonUtil.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/2/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import "TMReserveLessonUtil.h"

@interface TMReserveLessonUtil ()

@property (nonatomic,strong) NSMutableDictionary *lessons;
@property (nonatomic,assign) NSInteger order;

@end

@implementation TMReserveLessonUtil

+ (instancetype)sharedUtil {
    static TMReserveLessonUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
        sharedUtil.lessons = [NSMutableDictionary dictionary];
        sharedUtil.order = 0 ;
    });
    return sharedUtil;
}

-(void)reserveLesson:(TMLesson *)lesson{
    if(!lesson) return;
    
    lesson.order = ++_order;
    [_lessons setValue:lesson forKey:lesson.hashString];
    [self checkConflict];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedLessonsUpdateNotification object:self];
}

-(void)cancelLesson:(TMLesson *)lesson{
    if(!lesson) return ;

    [_lessons removeObjectForKey:lesson.hashString];
    [self checkConflict];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedLessonsUpdateNotification object:self];
}

-(void)clearLessons{
    _lessons = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedLessonsUpdateNotification object:self];
}

-(NSArray *)reservedLessonsOfType:(TMNClassSessionType) type{
    
    NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"sessionType == %lu", type];
    
    return [[self reservedLessons] filteredArrayUsingPredicate:predicate];
}

-(NSArray *)reservedLessons{

    NSArray *sortedArray;
        
    return sortedArray = [[_lessons allValues] sortedArrayUsingComparator:^NSComparisonResult(TMLesson *a, TMLesson *b) {
        NSInteger first = a.order;
        NSInteger second = b.order;
        if ( first < second ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( first > second ) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
}

-(NSArray *)lessonsConflictedWithLesson:(TMLesson *)lesson{
    
    NSMutableArray *array = [NSMutableArray array];;
    
    for (TMLesson *l in [_lessons allValues]){
        if([lesson isConflictWithLesson:l]){
            [array addObject:l];
        }
    }
    
    return array;
}

-(BOOL)reservedPowerSession{
    
    for (TMLesson *l in [_lessons allValues]){
        if (l.sessionType == TMNClassSessionType_1on2 ||
            l.sessionType == TMNClassSessionType_1on3 ||
            l.sessionType == TMNClassSessionType_1on4 ||
            l.sessionType == TMNClassSessionType_1on6) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)containLesson:(TMLesson *)lesson{
    if([_lessons valueForKey:lesson.hashString]){
        return YES;
    }
    
    return NO;
}

-(NSUInteger)count{
    if(_lessons){
        return _lessons.count;
    }
    return 0;
}

-(void)checkConflict{
    for (TMLesson *lesson in [_lessons allValues]){
        NSArray *cLesson = [self lessonsConflictedWithLesson:lesson];
        if(cLesson && cLesson.count >1){
            lesson.isConflict = YES;
        }else{
            lesson.isConflict = NO;
        }
    }
}

-(BOOL)containConflictLessons{
    for (TMLesson *lesson in [_lessons allValues]){
        if(lesson.isConflict){
            return YES;
        }
    }
    
    return NO;
}

@end
