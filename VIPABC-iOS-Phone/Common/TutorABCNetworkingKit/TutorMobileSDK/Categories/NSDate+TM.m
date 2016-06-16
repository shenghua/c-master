//
//  NSDate+TM.m
//  CalendarStoryBoard
//
//  Created by Oxy Hsing_邢傑 on 9/7/15.
//  Copyright (c) 2015 Oxy Hsing. All rights reserved.
//

#import "NSDate+TM.h"

@implementation NSDate (TM)

#pragma mark - Calculate the numOfDay of CalCollectionView
-(NSInteger)numberOfDaysInMonthCount {
    
    NSCalendar * calendar = [NSCalendar currentCalendar];

    NSRange dayRange = [calendar rangeOfUnit:NSCalendarUnitDay
                                      inUnit:NSCalendarUnitMonth
                                     forDate:self];
    
    return dayRange.length;
}

- (NSInteger)numberOfWeekInMonthCount {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSRange weekRange = [calender rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
    return weekRange.length;
}

#pragma mark - Statics Methods
+ (NSDateComponents *)componentsOfCurrentDate {
    
    return [NSDate componentsOfDate:[NSDate date]];
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [NSDate componentsWithYear:year month:month day:day];
    
    return [calendar dateFromComponents:components];
}

+ (NSDateComponents *)componentsOfDate:(NSDate *)date {
    
    return [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSCalendarUnitHour |
            NSCalendarUnitMinute fromDate:date];

}

+ (NSDateComponents *)componentsWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    
    return components;
}
+ (BOOL)isTheSameDateTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB {
    
    return ([compA day]==[compB day] && [compA month]==[compB month ]&& [compA year]==[compB year]);
}
+ (BOOL)isTheSameTimeTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB {
    
    return ([compA hour]==[compB hour] && [compA minute]==[compB minute]);
}

-(NSDate *) thisSunday{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:self];
    NSInteger day = [comp weekday];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -day +1;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *sunday = [theCalendar dateByAddingComponents:dayComponent toDate:self options:0];
    return sunday;
}

-(BOOL) isSameDay:(NSDate*) otherDate; {
    // Keep only day, year and month for self and other date
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    return [self isSameDate:otherDate withFlags:unitFlags];
}

-(BOOL) isSameMonth:(NSDate*) otherDate; {
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
 
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:otherDate];
    
    return ((components.year == components2.year) && (components.month == components2.month));
}

-(BOOL) isSameDate:(NSDate*) otherDate withFlags:(unsigned) unitFlags {
    NSCalendar* calender = [NSCalendar currentCalendar];
    
    NSDateComponents *truncatedComponents = [calender components:unitFlags fromDate:self];
    NSDate* truncatedSelf = [calender dateFromComponents:truncatedComponents];
    
    truncatedComponents = [calender components:unitFlags fromDate:otherDate];
    NSDate* truncatedOtherDate = [calender dateFromComponents:truncatedComponents];
    
    NSComparisonResult dateComparison = [truncatedSelf compare:truncatedOtherDate];
    return (dateComparison == NSOrderedSame);
}

-(NSDate *)normalize{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components ];
    
    return date;
}

+(NSDate *) firstDayOfMonthOf:(NSDate*) date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    components.day = 1;
    NSDate *firstDayOfMonthDate = [[NSCalendar currentCalendar] dateFromComponents:components ];
    
    return firstDayOfMonthDate;
}

-(NSDate *) firstDay{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];
    components.day = 1;
    NSDate *firstDayOfMonthDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return firstDayOfMonthDate;
}

+(NSDate *) dateInPeriod:(TMPeriod)period of:(NSDate *)date{
    switch (period) {
        case TMPeriod_Morning:{
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
            components.hour = 6;
            components.minute = 30;
            NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components ];
            
            return newDate;
        }
        case TMPeriod_Afternoon:{
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
            components.hour = 13;
            components.minute = 30;
            NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components ];
            
            return newDate;
        }
        case TMPeriod_Night:{
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
            components.hour = 18;
            components.minute = 30;
            NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components ];
            
            return newDate;
        }
        default:{
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
            components.hour = 0;
            components.minute = 0;
            NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:components ];
            
            return newDate;
        }
    }
}

+(NSDate *) monthOfIndex:(NSInteger) index {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:(index-kCurrent_Month_Index)];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate firstDayOfMonthOf:[NSDate date]] options:0];
    return newDate;
}

-(NSInteger) indexOfThisMonth{

    NSInteger month = [[[NSCalendar currentCalendar] components: NSCalendarUnitMonth
                                                       fromDate: [NSDate date].firstDay
                                                         toDate: self.firstDay
                                                        options: 0] month];
    
    return kCurrent_Month_Index +month;
}

-(NSDate *) nextDay{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:1];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

-(NSDate *) nextMonth{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:31];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

-(NSString *) stringFormat1{
    return [self stringWithFormat:@"yyyy 年 MMM"];
}

-(NSString *) stringFormat2{

    return [self stringWithFormat:@"MMM dd 日 eee"];
}

-(NSString *) stringFormat3{
    return [self stringWithFormat:@"MMM"];
}

-(NSString *) stringFormat4{
    return [self stringWithFormat:@"HH:mm"];
}

-(NSString *) stringFormat5{
    return [self stringWithFormat:@"MMMd日 eee HH:mm"];
}

-(NSString *) stringFormat6{
    return [self stringWithFormat:@"MM/dd HH:mm"];
}

-(NSString *) stringFormat7{
    return [self stringWithFormat:@"MMMd日 HH:mm"];
}

-(NSString *) stringWithFormat:(NSString *) format{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_Hant_TW"]];
    
    [dateFormatter setDateFormat:format];
    
    
    NSString *localetime = [dateFormatter stringFromDate:self];
    
    return localetime;
}

-(long long) unixTimestamp{
    return (long long)([self timeIntervalSince1970] * 1000);
}

+(NSDate *) dateWithTimestamp:(long long) timestamp{
    return [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
}


@end
