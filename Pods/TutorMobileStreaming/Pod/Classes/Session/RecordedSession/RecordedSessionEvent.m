//
//  RecordedSessionEvent.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/19.
//
//

#import "RecordedSessionEvent.h"
#import "SessionConstants.h"

@implementation RecordedSessionEvent
- (instancetype)initWithInfo:(NSArray *)eventInfo {
    // eventInfo sample data: 1444922322556, r, Christopher Johnson~1900|1|2
    NSAssert(eventInfo && [eventInfo count] >= 3, @"info should not be nil!!");
    
    self = [super init];
    if (self) {
        // Set eventTime
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *timeNum = [f numberFromString:eventInfo[0]];
        _eventTime = [timeNum longLongValue];
        
        // Set eventType
        _eventType = [self _getEventType:eventInfo[1]];
                      
        // Set eventParams
        _eventParams = [(NSString *)eventInfo[2] componentsSeparatedByString:@"|"];
        
        // Set event
        _event = [(NSString *)eventInfo[3] copy];
    }
    return self;
}
                      
- (RecordedSessionEventType)_getEventType:(NSString *)eventType {
    if ([eventType isEqualToString:kRecordedSessionEvent_Init])
        return RecordedSessionEventType_Init;
    else if ([eventType isEqualToString:kRecordedSessionEvent_Logout])
        return RecordedSessionEventType_Logout;
    else if ([eventType isEqualToString:kRecordedSessionEvent_Record])
        return RecordedSessionEventType_Record;
    else if ([eventType isEqualToString:kRecordedSessionEvent_Chat])
        return RecordedSessionEventType_Chat;
    else if ([eventType isEqualToString:kRecordedSessionEvent_Time])
        return RecordedSessionEventType_Time;
    else if ([eventType isEqualToString:kRecordedSessionEvent_ClapHands])
        return RecordedSessionEventType_ClapHands;
    else if ([eventType isEqualToString:kRecordedSessionEvent_Page])
        return RecordedSessionEventType_Page;
    else if ([eventType isEqualToString:kRecordedSessionEvent_Shape])
        return RecordedSessionEventType_Shape;
    else if ([eventType isEqualToString:kRecordedSessionEvent_DeleteShape])
        return RecordedSessionEventType_DeleteShape;
    else if ([eventType isEqualToString:kRecordedSessionEvent_ClearShapes])
        return RecordedSessionEventType_ClearShapes;
    else if ([eventType isEqualToString:kRecordedSessionEvent_Mouse])
        return RecordedSessionEventType_Mouse;
    else if ([eventType isEqualToString:kRecordedSessionEvent_Pointer])
        return RecordedSessionEventType_Pointer;
    else
        return RecordedSessionEventType_Unknown;
}

@end
