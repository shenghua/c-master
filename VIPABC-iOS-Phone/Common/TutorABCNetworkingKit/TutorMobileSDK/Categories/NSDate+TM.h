//
//  NSDate+TM.h
//  CalendarStoryBoard
//
//  Created by Oxy Hsing_邢傑 on 9/7/15.
//  Copyright (c) 2015 Oxy Hsing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNConstants.h"

#define kCurrent_Month_Index 120

@interface NSDate (TM)

// Cale Number Of Day within one Month
-(NSInteger)numberOfDaysInMonthCount;
// Cal Number of Week in Each Month
- (NSInteger)numberOfWeekInMonthCount;

+ (NSDateComponents *)componentsOfCurrentDate;
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (NSDateComponents *)componentsOfDate:(NSDate *)date;
+ (NSDateComponents *)componentsWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (BOOL)isTheSameDateTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB;
+ (BOOL)isTheSameTimeTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB;

-(NSDate *) thisSunday;
-(BOOL) isSameDay:(NSDate*) otherDate;
-(BOOL) isSameMonth:(NSDate*) otherDate;
-(BOOL) isSameDate:(NSDate*) otherDate withFlags:(unsigned) unitFlags;

-(NSDate *) normalize;
+(NSDate *) firstDayOfMonthOf:(NSDate*) date;
//+(NSDate *) morningOf:(NSDate*) date;
//+(NSDate *) noonOf:(NSDate*) date;
//+(NSDate *) afternoonOf:(NSDate*) date;
+(NSDate *) monthOfIndex:(NSInteger) index;
-(NSInteger) indexOfThisMonth;

+(NSDate *) dateInPeriod:(TMPeriod)period of:(NSDate *)date;

-(NSDate *) nextDay;
-(NSDate *) nextMonth;

-(NSString *) stringFormat1;
-(NSString *) stringFormat2;
-(NSString *) stringFormat3;
-(NSString *) stringFormat4;
-(NSString *) stringFormat5;
-(NSString *) stringFormat6;
-(NSString *) stringFormat7;
-(long long) unixTimestamp;

+(NSDate *) dateWithTimestamp:(long long) timestamp;
@end
