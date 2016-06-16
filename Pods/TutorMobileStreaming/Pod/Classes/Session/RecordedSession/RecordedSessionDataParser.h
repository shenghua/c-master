//
//  RecordedSessionDataParser.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/16.
//
//

#import <Foundation/Foundation.h>
#import "RecordedSessionEvent.h"
#import "SessionWhiteboardObject.h"
#import "SessionChatMessage.h"

@protocol RecordedSessionDataParserDelegate <NSObject>
- (void)onRecordedSessionDataParserDone:(BOOL)success;
@end

@interface RecordedSessionDataParser : NSObject <NSXMLParserDelegate>
@property (nonatomic, assign, readonly) BOOL isLobbySession;
@property (nonatomic, assign, readonly) long long sessionInitTime;
@property (nonatomic, assign, readonly) long long sessionStartTime;
@property (nonatomic, assign, readonly) long long sessionEndTime;
@property (nonatomic, strong) NSMutableArray *recordedSessionEventList;
@property (nonatomic, strong) NSMutableDictionary *recordedSessionStreamList;
@property (nonatomic, assign, readonly) int totalWbPages;
    
- (instancetype)initWithSessionSn:(NSString *)sessionSn
                         serverIp:(NSString *)serverIp
                    classStartMin:(NSString *)classStartMin
                         delegate:(id<RecordedSessionDataParserDelegate>)delegate;
- (void)startParser;
- (void)stopParser;
- (void)releaseParser;

- (NSArray<SessionWhiteboardObject *> *)getSessionWbObjectsAheadOfTimestamp:(long long)timestamp;   // Get list of merged wbObjects ahead of timestamp
- (BOOL)getWebPointerPosAheadOfTimestamp:(long long)timestamp point:(CGPoint *)point;               // Get the web pointer position ahead of timestamp
- (BOOL)getWebMousePosAheadOfTimestamp:(long long)timestamp point:(CGPoint *)point;                 // Get the web mouse position ahead of timestamp
- (NSArray<SessionChatMessage *> *)getChatMessagesAheadOfTimestamp:(long long)timestamp;            // Get all chat messages ahead of timestamp
- (SessionWhiteboardObject *)genSessionWhiteboardObject:(RecordedSessionEvent *)sessionEvent;       // Get SessionWhiteboardObject by RecordedSessionEvent
- (SessionChatMessage *)genChatMessage:(RecordedSessionEvent *)sessionEvent;                        // Get SessionChatMessage by RecordedSessionEvent
- (long long)getTimestampbyCuePointEvent:(NSString *)event fromTimestamp:(long long)timestamp;      // Get the timestamp by the provided cue point event
@end
