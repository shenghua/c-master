//
//  RecordedSessionEvent.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/19.
//
//

#import <Foundation/Foundation.h>

typedef enum _RecordedSessionEventType {
    RecordedSessionEventType_Unknown,
    
    RecordedSessionEventType_Init,
    RecordedSessionEventType_Logout,
    RecordedSessionEventType_Record,
    RecordedSessionEventType_Chat,
    RecordedSessionEventType_Time,
    RecordedSessionEventType_ClapHands,
    // Whiteboard
    RecordedSessionEventType_Page,
    RecordedSessionEventType_Shape,
    RecordedSessionEventType_DeleteShape,
    RecordedSessionEventType_ClearShapes,
    RecordedSessionEventType_Mouse,
    RecordedSessionEventType_Pointer
} RecordedSessionEventType;

@interface RecordedSessionEvent : NSObject
@property (nonatomic, assign, readonly) long long eventTime;
@property (nonatomic, assign, readonly) RecordedSessionEventType eventType;
@property (nonatomic, strong, readonly) NSArray<NSString *> *eventParams;
@property (nonatomic, strong, readonly) NSString *event;

- (instancetype)initWithInfo:(NSArray *)eventInfo;
@end
