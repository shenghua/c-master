//
//  RecordedSessionDataParser.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/16.
//
//

#import "RecordedSessionDataParser.h"
#import "RecordedSessionImageInfo.h"
#import "RecordedSessionStream.h"
#import "SessionConstants.h"
#import "TutorLog.h"

#define kWebHostName                @"www.tutormeet.com"
#define kPlaybackWebHostName        @"203.69.82.154:81"
#define kImageNameUrlIntegration    @"/materials/php/listFiles.php"
#define kImageNameUrlPlayback       @"/mr/php/listFiles.php"
#define kImageNameUrlPlayback1      @"/mr1/php/listFiles.php"
#define kImageNameUrlPlayback2      @"/mr2/php/listFiles.php"
#define kImageNameUrlPlayback3      @"/mr3/php/listFiles.php"
#define kImageNameUrlPlayback4      @"/mr4/php/listFiles.php"

@interface RecordedSessionDataParser()
@property (nonatomic, assign) BOOL parsing;
@property (nonatomic, weak) id<RecordedSessionDataParserDelegate> delegate;
@property (nonatomic, strong) NSString *sessionSn;
@property (nonatomic, strong) NSString *serverIp;
@property (nonatomic, strong) NSString *classStartMin;
@property (nonatomic) dispatch_queue_t taskQueue;
@property (nonatomic, strong) NSMutableDictionary *imageInfoDict;   // Start from 01.png
@property (nonatomic, strong) NSString *imageNameFolderUrl;

@end

@implementation RecordedSessionDataParser
- (instancetype)initWithSessionSn:(NSString *)sessionSn
                         serverIp:(NSString *)serverIp
                    classStartMin:(NSString *)classStartMin
                   delegate:(id<RecordedSessionDataParserDelegate>)delegate {
    self = [super init];
    if (self) {
        _parsing = NO;
        _sessionSn = [sessionSn copy];
        _serverIp = [serverIp copy];
        _classStartMin = [classStartMin copy];
        _delegate = delegate;
        _taskQueue = dispatch_queue_create("RecordedSessionDataParser Task queue", DISPATCH_QUEUE_SERIAL);
        _imageInfoDict = [NSMutableDictionary new];
        _recordedSessionEventList = [NSMutableArray new];
        _recordedSessionStreamList = [NSMutableDictionary new];
    }
    return self;
}

- (void)startParser {
    _parsing = YES;
    [self _fetchWhiteboardMaterials];
    [self _fetchWhiteboardData];
}

- (void)stopParser {
    _parsing = NO;
}

- (void)releaseParser {
    [self stopParser];
    
    [_imageInfoDict removeAllObjects];
    _imageInfoDict = nil;
    [_recordedSessionEventList removeAllObjects];
    _recordedSessionEventList = nil;
    [_recordedSessionStreamList removeAllObjects];
    _recordedSessionStreamList = nil;
}

- (SessionWhiteboardObject *)genSessionWhiteboardObject:(RecordedSessionEvent *)sessionEvent {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    SessionWhiteboardObject *sessionWbObject = [SessionWhiteboardObject new];
    
    switch (sessionEvent.eventType) {
        case RecordedSessionEventType_Page:
        {
            int pageNum = [sessionEvent.eventParams[0] intValue];
            sessionWbObject.objId = 0;  // Fixed obj id for image shape
            sessionWbObject.shape = WhiteboardShape_Image;
            sessionWbObject.properties[@(0)] = @(5);
            sessionWbObject.properties[@(1)] = @(5);
            sessionWbObject.properties[@(2)] = @(sessionWbObject.objId);
            sessionWbObject.properties[@(3)] = @(701);  //@(((RecordedSessionImageInfo *)_imageInfoDict[@(pageNum)]).width);
            sessionWbObject.properties[@(4)] = @(528);  //@(((RecordedSessionImageInfo *)_imageInfoDict[@(pageNum)]).height);
            sessionWbObject.properties[@(5)] = [NSString stringWithFormat:@"%@%@", _imageNameFolderUrl, ((RecordedSessionImageInfo *)_imageInfoDict[@(pageNum)]).name];
            sessionWbObject.properties[@(8)] = @(1);
            break;
        }
        case RecordedSessionEventType_Shape:
        {
            int objId = [sessionEvent.eventParams[[sessionEvent.eventParams count] - 1] intValue];
            sessionWbObject.objId = objId;
            sessionWbObject.shape = (WhiteboardShape)[[f numberFromString:sessionEvent.eventParams[1]] intValue];
            [sessionWbObject.properties removeAllObjects];
            switch (sessionWbObject.shape) {
                case WhiteboardShape_Line:
                case WhiteboardShape_Rectangle:
                case WhiteboardShape_Circle:
                    // Line:        1444923198347-s-a|1|74 |232|577.00|0.00  |4|255     |0      |2
                    // Rectangle:   1429623087673-s-a|2|417|180|302.00|161.00|3|16711680|0      |1
                    // Circle:      1429623696142-s-a|3|781|151|124.00|124.00|4|0       |6736947|5
                    // |  Line     | Rectangle |   Circle  |
                    sessionWbObject.properties[@(0)] = [f numberFromString:sessionEvent.eventParams[2]];    // | x         | x         | x         |
                    sessionWbObject.properties[@(1)] = [f numberFromString:sessionEvent.eventParams[3]];    // | y         | y         | y         |
                    sessionWbObject.properties[@(2)] = @(sessionWbObject.objId);                            // | objId     | objId     | objId     |
                    sessionWbObject.properties[@(3)] = [f numberFromString:sessionEvent.eventParams[4]];    // | diffX     | width     | width     |
                    sessionWbObject.properties[@(4)] = [f numberFromString:sessionEvent.eventParams[5]];    // | diffY     | height    | height    |
                    sessionWbObject.properties[@(5)] = [f numberFromString:sessionEvent.eventParams[6]];    // | lineSize  | lineSize  | lineSize  |
                    sessionWbObject.properties[@(6)] = [f numberFromString:sessionEvent.eventParams[7]];    // | lineColor | lineColor | lineColor |
                    sessionWbObject.properties[@(7)] = [f numberFromString:sessionEvent.eventParams[8]];    // | type      | fillColor | fillColor |
                    
                    break;
                case WhiteboardShape_Triangle:
                    // Triangle:
                    
                    sessionWbObject.properties[@(0)] = [f numberFromString:sessionEvent.eventParams[2]];    // | x         |
                    sessionWbObject.properties[@(1)] = [f numberFromString:sessionEvent.eventParams[3]];    // | y         |
                    sessionWbObject.properties[@(2)] = @(sessionWbObject.objId);                            // | objId     |
                    sessionWbObject.properties[@(3)] = [f numberFromString:sessionEvent.eventParams[4]];    // | width     |
                    sessionWbObject.properties[@(4)] = [f numberFromString:sessionEvent.eventParams[5]];    // | height    |
                    sessionWbObject.properties[@(5)] = [f numberFromString:sessionEvent.eventParams[6]];    // | lineSize  |
                    sessionWbObject.properties[@(6)] = [f numberFromString:sessionEvent.eventParams[7]];    // | lineColor |
                    sessionWbObject.properties[@(7)] = [f numberFromString:sessionEvent.eventParams[8]];    // | fillColor |
                    sessionWbObject.properties[@(7)] = [f numberFromString:sessionEvent.eventParams[9]];    // | type      |
                    break;
                    
                case WhiteboardShape_Freehand:
                case WhiteboardShape_Marker:
                    // Freehand:    1444923603778-s-a|6 |251|210|0.00|0.00|3 |255    |4,15|4,15|4,14|3,12|2,9|2,5|2,4|1,2|0,1|0,0|15
                    // Marker:      1429623896838-s-a|11|598|117|0.00|0.00|16|6750003|0,0|0,0|1,0|3,0|9,2|16,3|19,4              |7
                    
                    sessionWbObject.properties[@(0)] = [f numberFromString:sessionEvent.eventParams[2]];    // | x         |
                    sessionWbObject.properties[@(1)] = [f numberFromString:sessionEvent.eventParams[3]];    // | y         |
                    sessionWbObject.properties[@(2)] = @(sessionWbObject.objId);                            // | objId     |
                    sessionWbObject.properties[@(3)] = [f numberFromString:sessionEvent.eventParams[6]];    // | lineSize  |
                    sessionWbObject.properties[@(4)] = [f numberFromString:sessionEvent.eventParams[7]];    // | lineColor |
                    sessionWbObject.properties[@(5)] = [NSMutableArray new];                                // | points    |
                    for (int i = 8; i < [sessionEvent.eventParams count] - 1; i++) {
                        NSArray *xy = [sessionEvent.eventParams[i] componentsSeparatedByString:@","];
                        [sessionWbObject.properties[@(5)] addObject:@[[f numberFromString:xy[0]], [f numberFromString:xy[1]]]];
                    }
                    
                    break;
                    
                case WhiteboardShape_Text:
                    // Text: 1429623549757-s-a|7|417|296|250.00|31.25|255|this is a test|_sans|9|false|false|false|22
                    
                    sessionWbObject.properties[@(0)]  = [f numberFromString:sessionEvent.eventParams[2]];                       // | x         |
                    sessionWbObject.properties[@(1)]  = [f numberFromString:sessionEvent.eventParams[3]];                       // | y         |
                    sessionWbObject.properties[@(2)]  = @(sessionWbObject.objId);                                               // | objId     |
                    sessionWbObject.properties[@(3)]  = [f numberFromString:sessionEvent.eventParams[4]];                       // | width     |
                    sessionWbObject.properties[@(4)]  = [f numberFromString:sessionEvent.eventParams[5]];                       // | height    |
                    sessionWbObject.properties[@(5)]  = [f numberFromString:sessionEvent.eventParams[6]];                       // | color     |
                    sessionWbObject.properties[@(6)]  = [sessionEvent.eventParams[7] copy];                                     // | text      |
                    sessionWbObject.properties[@(7)]  = [sessionEvent.eventParams[8] copy];                                     // | font      |
                    sessionWbObject.properties[@(8)]  = [f numberFromString:sessionEvent.eventParams[9]];                       // | fontSize  |
                    sessionWbObject.properties[@(9)]  = [sessionEvent.eventParams[10] isEqualToString:@"true"] ? @(1) : @(0);   // | bold      |
                    sessionWbObject.properties[@(10)] = [sessionEvent.eventParams[11] isEqualToString:@"true"] ? @(1) : @(0);   // | italic    |
                    sessionWbObject.properties[@(11)] = [sessionEvent.eventParams[12] isEqualToString:@"true"] ? @(1) : @(0);   // | underline |
                    break;
                    
                case WhiteboardShape_Image:
                    // Image: 1429624234106-s-a|10|10|10|75.00|75.00|1|-1|http://www.tutormeet.com/sticker/assets/100.png|12
                    
                    sessionWbObject.properties[@(0)]  = [f numberFromString:sessionEvent.eventParams[2]];    // | x         |
                    sessionWbObject.properties[@(1)]  = [f numberFromString:sessionEvent.eventParams[3]];    // | y         |
                    sessionWbObject.properties[@(2)]  = @(sessionWbObject.objId);                            // | objId     |
                    sessionWbObject.properties[@(3)]  = [f numberFromString:sessionEvent.eventParams[4]];    // | width     |
                    sessionWbObject.properties[@(4)]  = [f numberFromString:sessionEvent.eventParams[5]];    // | height    |
                    sessionWbObject.properties[@(5)]  = [sessionEvent.eventParams[8] copy];                  // | url       |
                    sessionWbObject.properties[@(8)]  = @(1);                                                // | is image  |
                    break;
                    
                default:
                    break;
            }

            break;
        }
        default:
            sessionWbObject = nil;
            break;
    }
    
    return sessionWbObject;
}

- (NSArray<SessionWhiteboardObject *> *)getSessionWbObjectsAheadOfTimestamp:(long long)timestamp {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSMutableDictionary *sessionWbObjects = [NSMutableDictionary new];
    
    for (RecordedSessionEvent *sessionEvent in _recordedSessionEventList) {
        if (sessionEvent.eventTime > timestamp)
            break;
        
        switch (sessionEvent.eventType) {
            case RecordedSessionEventType_Page:
            {
                // Clear sessionWbObjects since page is changed
                [sessionWbObjects removeAllObjects];
                
                SessionWhiteboardObject *sessionWbObject = [self genSessionWhiteboardObject:sessionEvent];
                sessionWbObjects[@(sessionWbObject.objId)] = @[@(sessionEvent.eventTime) ,sessionWbObject];
                break;
            }
            case RecordedSessionEventType_Shape:
            {
                int objId = [sessionEvent.eventParams[[sessionEvent.eventParams count] - 1] intValue];
                
                if (sessionWbObjects[@(objId)])
                    [sessionWbObjects removeObjectForKey:sessionWbObjects[@(objId)]];
                    
                SessionWhiteboardObject *sessionWbObject = [self genSessionWhiteboardObject:sessionEvent];
                sessionWbObjects[@(sessionWbObject.objId)] = @[@(sessionEvent.eventTime) ,sessionWbObject];
                break;
            }
            case RecordedSessionEventType_DeleteShape:
            {
                if (sessionWbObjects[@([sessionEvent.eventParams[0] intValue])])
                    [sessionWbObjects removeObjectForKey:@([sessionEvent.eventParams[0] intValue])];
                break;
            }
            case RecordedSessionEventType_ClearShapes:
            {
                break;
            }
            default:
                break;
        }
    }
    
    // Sort sessionWbObjects by timestamp
    NSArray *sorted = [[sessionWbObjects allValues] sortedArrayWithOptions:0 usingComparator:^(id v1, id v2) {
        long long f1 = [((NSNumber *)(((NSArray *)v1)[0])) longLongValue];
        long long f2 = [((NSNumber *)(((NSArray *)v2)[0])) longLongValue];
        
        if (f1 == f2) return NSOrderedSame;
        return (f1 < f2) ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSMutableArray *sortedSessionWbObjects = [NSMutableArray new];
    [sorted enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sortedSessionWbObjects addObject:obj[1]];
    }];
    
    return sortedSessionWbObjects;
}

- (BOOL)getWebPointerPosAheadOfTimestamp:(long long)timestamp point:(CGPoint *)point {
    BOOL hasPoint = NO;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    for (RecordedSessionEvent *sessionEvent in _recordedSessionEventList) {
        if (sessionEvent.eventTime > timestamp)
            break;
        
        if (sessionEvent.eventType == RecordedSessionEventType_Pointer) {
            hasPoint = YES;
            point->x = [[f numberFromString:sessionEvent.eventParams[0]] floatValue];
            point->y = [[f numberFromString:sessionEvent.eventParams[1]] floatValue];
        }
    }
    
    return hasPoint;
}

- (BOOL)getWebMousePosAheadOfTimestamp:(long long)timestamp point:(CGPoint *)point{
    BOOL hasPoint = NO;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    for (RecordedSessionEvent *sessionEvent in _recordedSessionEventList) {
        if (sessionEvent.eventTime > timestamp)
            break;
        
        if (sessionEvent.eventType == RecordedSessionEventType_Mouse) {
            hasPoint = YES;
            point->x = [[f numberFromString:sessionEvent.eventParams[0]] floatValue];
            point->y = [[f numberFromString:sessionEvent.eventParams[1]] floatValue];
        }
    }
    
    return hasPoint;
}

- (SessionChatMessage *)genChatMessage:(RecordedSessionEvent *)sessionEvent {
    SessionChatMessage *chatMessage = nil;
    
    if (sessionEvent.eventType == RecordedSessionEventType_Chat) {
        if ([sessionEvent.eventParams count] == 1) {
            // 1444922986486-c-<h1>Siglinde de Villiers 14:30:20</h1><h3>Namibia</h3>
            NSRange messageStartRange = [[sessionEvent.eventParams[0] substringFromIndex:4] rangeOfString:@"<"];
            NSString *message = [sessionEvent.eventParams[0] substringFromIndex:4 + messageStartRange.location + 9];
            message  = [message substringToIndex:message.length - 5];
            
            NSString *time = [[sessionEvent.eventParams[0] substringFromIndex:4] substringWithRange:NSMakeRange(messageStartRange.location - 8, 8)];
            
            NSString *userName = [sessionEvent.eventParams[0] substringFromIndex:4];
            NSRange userNameRange = [userName rangeOfString:time];
            userName = [userName substringToIndex:userNameRange.location - 1];
            
            SessionChatMessagePriority priority = [userName rangeOfString:@"IT"].location != NSNotFound ? SessionChatMessagePriority_High : SessionChatMessagePriority_Normal;
            chatMessage = [[SessionChatMessage alloc] initWithUserName:userName time:time message:message priority:priority];
        }
        else if ([sessionEvent.eventParams count] == 2) {
            // 1444922986486-c-<h1>Mia zhong 23:29:46</h1>|hello
            NSRange userNameRange = NSMakeRange(4, sessionEvent.eventParams[0].length - 4 - 1 - 8 - 5);
            NSRange timeRange = NSMakeRange(4 + userNameRange.length, 9);
            NSString *userName = [sessionEvent.eventParams[0] substringWithRange:userNameRange];
            NSString *time = [sessionEvent.eventParams[0] substringWithRange:timeRange];
            
            SessionChatMessagePriority priority = [userName rangeOfString:@"IT"].location != NSNotFound ? SessionChatMessagePriority_High : SessionChatMessagePriority_Normal;
            chatMessage = [[SessionChatMessage alloc] initWithUserName:userName time:time message:sessionEvent.eventParams[1] priority:priority];
        }
    }
    
    return chatMessage;
}

- (long long)getTimestampbyCuePointEvent:(NSString *)event fromTimestamp:(long long)fromTimestamp {
    long long timestamp = 0;
    
    for (RecordedSessionEvent *sessionEvent in _recordedSessionEventList) {
        if (sessionEvent.eventTime < fromTimestamp)
            continue;
        
        if ([sessionEvent.event rangeOfString:event].location != NSNotFound) {
            timestamp = sessionEvent.eventTime;
            break;
        }
    }
    
    return timestamp;
}

- (NSArray<SessionChatMessage *> *)getChatMessagesAheadOfTimestamp:(long long)timestamp {
    NSMutableArray *chatMessages = [NSMutableArray new];
    
    for (RecordedSessionEvent *sessionEvent in _recordedSessionEventList) {
        if (sessionEvent.eventTime > timestamp)
            break;
        
        SessionChatMessage *chatMessage = [self genChatMessage:sessionEvent];
        if (chatMessage)
            [chatMessages addObject:chatMessage];
    }
    
    return chatMessages;
}

#pragma mark - Parser Helper Methods
- (void)_fetchWhiteboardMaterials {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"Fetching whiteboard materials start");
        
        NSString *sessionRoomId = [NSString stringWithFormat:@"session%@", [_sessionSn substringFromIndex:10]];
        
        for (int retry = 0; retry <= 5; retry++) {
            if (!_parsing) {
                DDLogDebug(@"Fetching whiteboard materials terminated");
                return;
            }
            
            NSString *imageNameUrlPrefix;
            NSString *imageFolderUrlPrefix;
            if (retry == 0) {
                imageNameUrlPrefix = [NSString stringWithFormat:@"http://%@%@", kPlaybackWebHostName, kImageNameUrlPlayback4];
                imageFolderUrlPrefix = [NSString stringWithFormat:@"http://%@/mr4/%@/", kPlaybackWebHostName, [_sessionSn substringToIndex:6]];
            }
            else if (retry == 1) {
                imageNameUrlPrefix = [NSString stringWithFormat:@"http://%@%@", kPlaybackWebHostName, kImageNameUrlPlayback3];
                imageFolderUrlPrefix = [NSString stringWithFormat:@"http://%@/mr3/%@/", kPlaybackWebHostName, [_sessionSn substringToIndex:6]];
            }
            else if (retry == 2) {
                imageNameUrlPrefix = [NSString stringWithFormat:@"http://%@%@", kPlaybackWebHostName, kImageNameUrlPlayback2];
                imageFolderUrlPrefix = [NSString stringWithFormat:@"http://%@/mr2/%@/", kPlaybackWebHostName, [_sessionSn substringToIndex:6]];
            }
            else if (retry == 3) {
                imageNameUrlPrefix = [NSString stringWithFormat:@"http://%@%@", kPlaybackWebHostName, kImageNameUrlPlayback1];
                imageFolderUrlPrefix = [NSString stringWithFormat:@"http://%@/mr1/%@/", kPlaybackWebHostName, [_sessionSn substringToIndex:6]];
            }
            else if (retry == 4) {
                imageNameUrlPrefix = [NSString stringWithFormat:@"http://%@%@", kPlaybackWebHostName, kImageNameUrlPlayback];
                imageFolderUrlPrefix = [NSString stringWithFormat:@"http://%@/mr/%@/", kPlaybackWebHostName, [_sessionSn substringToIndex:6]];
            }
            else {
                imageNameUrlPrefix = [NSString stringWithFormat:@"http://%@%@", kWebHostName, kImageNameUrlIntegration];
                imageFolderUrlPrefix = [NSString stringWithFormat:@"http://%@/materials/", kWebHostName];
            }
            
            NSString *imageNameUrl = [NSString stringWithFormat:@"%@?filepath=%@_%@&dir=%@&rnd=%d", imageNameUrlPrefix, sessionRoomId, _sessionSn, [_sessionSn substringToIndex:6], arc4random_uniform(1000)];
            _imageNameFolderUrl = [NSString stringWithFormat:@"%@%@_%@/", imageFolderUrlPrefix, sessionRoomId, _sessionSn];
            
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:imageNameUrl]];
            if (xmlParser) {
                [xmlParser setDelegate:self];
                [xmlParser parse];
                
                if ([_imageInfoDict count]) {
                    _totalWbPages = (int)[_imageInfoDict count];
                    DDLogDebug(@"Fetch whiteboard images (%d) successfully!! imageNameFolderFurl (%@), imageNameUrl (%@)", _totalWbPages, _imageNameFolderUrl, imageNameUrl);
                    break;
                }
            }
        }
        DDLogDebug(@"Fetching whiteboard materials end");
    });
}

- (void)_fetchWhiteboardData {
    dispatch_async(_taskQueue, ^{
        DDLogDebug(@"Fetching whiteboard data start");
        
        NSString *sessionRoomId = [NSString stringWithFormat:@"session%@", [_sessionSn substringFromIndex:10]];
        
        for (int retry = 0; retry <= 11; retry++) {
            if (!_parsing) {
                DDLogDebug(@"Fetching whiteboard data terminated");
                return;
            }
            
            NSString *wbDataUrl = nil;
            
            if (retry == 0)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb_%@/%@_%@.%@?rnd=%d", _serverIp, @"recording4", [_sessionSn substringToIndex:6], sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 1)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb_%@/%@_%@.%@?rnd=%d", _serverIp, @"recording3", [_sessionSn substringToIndex:6], sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 2)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb_%@/%@_%@.%@?rnd=%d", _serverIp, @"recording2", [_sessionSn substringToIndex:6], sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 3)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb_%@/%@_%@.%@?rnd=%d", _serverIp, @"recording1", [_sessionSn substringToIndex:6], sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 4)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb_%@/%@_%@.%@?rnd=%d", _serverIp, @"recording", [_sessionSn substringToIndex:6], sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 5)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb/%@_%@.%@?rnd=%d", _serverIp, @"recording4", sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 6)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb/%@_%@.%@?rnd=%d", _serverIp, @"recording3", sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 7)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb/%@_%@.%@?rnd=%d", _serverIp, @"recording2", sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 8)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb/%@_%@.%@?rnd=%d", _serverIp, @"recording1", sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 9)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb/%@_%@.%@?rnd=%d", _serverIp, @"recording", sessionRoomId, _sessionSn , @"utf8", arc4random_uniform(1000)];
            
            else if (retry == 10)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb_%@/%@_%@.%@?rnd=%d", _serverIp, @"recording", [_sessionSn substringToIndex:6], sessionRoomId, _sessionSn , @"log", arc4random_uniform(1000)];
            
            else if (retry == 11)
                wbDataUrl = [NSString stringWithFormat:@"http://%@:81/%@/wb/%@_%@.%@?rnd=%d", _serverIp, @"recording", sessionRoomId, _sessionSn , @"log", arc4random_uniform(1000)];
            
            if (wbDataUrl) {
                DDLogDebug(@"Fetching whiteboard data (%@)", wbDataUrl);
                NSData *response = [self _sendSyncHttpGetRequest:wbDataUrl];
                if ([self _parseWbData:response])
                    break;
            }
        }
        
        // Call back parsed result
        if (_delegate && [_delegate respondsToSelector:@selector(onRecordedSessionDataParserDone:)])
            [_delegate onRecordedSessionDataParserDone:[_recordedSessionEventList count] > 0 ? YES : NO];
        
        DDLogDebug(@"Fetching whiteboard data end");
    });
}

- (BOOL)_parseWbData:(NSData *)data {
    DDLogDebug(@"Parsing whiteboard data start");
    
    BOOL success = NO;
    NSString *wbDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Sorting lines by timestamp
    NSArray *lines = [wbDataStr componentsSeparatedByString:@"\n"];
    lines = [lines sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *line in lines) {
        if (!_parsing) {
            DDLogDebug(@"Parsing whiteboard data terminated");
            return NO;
        }
        
        NSString *trimedLine = line;
        
        // Remove the last '\r'
        if ([line characterAtIndex:[line length] - 1] == '\r')
            trimedLine = [line substringToIndex:[line length] - 1];
        
        // First line sample data: 1444922319251-a-init4
        // Check if it is a valid wb file or not
        if ([trimedLine rangeOfString:@"-a-init"].location != NSNotFound) {
            DDLogDebug(@"Valid wb file found");
            success = YES;
        }
        
        if (success) {
            // Ex. 1429623379803-s-a|7|761|243|250.00|110.00|255|text - text|_sans|6|false|false|false|3
            
            NSRange rangeHyphen1 = [trimedLine rangeOfString:@"-"];
            if (rangeHyphen1.location == NSNotFound)
                continue;
            NSRange rangeHyphen2 = [[trimedLine substringFromIndex:rangeHyphen1.location + 1] rangeOfString:@"-"];
            if (rangeHyphen2.location == NSNotFound)
                continue;
            
            NSArray *infoArray = @[[trimedLine substringToIndex:rangeHyphen1.location],
                                   [[trimedLine substringFromIndex:rangeHyphen1.location + 1] substringToIndex:rangeHyphen2.location],
                                   [trimedLine substringFromIndex:rangeHyphen1.location + 1 + rangeHyphen2.location + 1],
                                   trimedLine];
            
            DDLogDebug(@"Line parsed: %@, %@, %@", infoArray[0], infoArray[1], infoArray[2]);
            RecordedSessionEvent *sessionEvent = [[RecordedSessionEvent alloc] initWithInfo:infoArray];
            if (sessionEvent)
                [_recordedSessionEventList addObject:sessionEvent];
        }
    }
    
    if (success)
        [self _parseRecordedSessionEvents];
    
    DDLogDebug(@"Parsing whiteboard data end (%d)", success);
    return success;
}

- (void)_parseRecordedSessionEvents {
    DDLogDebug(@"Parsing RecordedSessionEvents start");
    
    long long normalClassTime = 0;
    long long presenterLoginTime = 0;
    long long firstStudentTime = 0;
    
    for (RecordedSessionEvent *sessionEvent in _recordedSessionEventList) {
        if (!_parsing) {
            DDLogDebug(@"Parsing RecordedSessionEvents terminated");
            break;
        }
        
        switch (sessionEvent.eventType) {
            case RecordedSessionEventType_Init:
            {
                _sessionInitTime = sessionEvent.eventTime;
                break;
            }
            case RecordedSessionEventType_Record:
            {
                // Ex. 1429622472719-r-Siglinde de Villiers~5255|1|1    (publish name|is presenter|room type)
                
                // 1. Set SessionStartTime, isLobbySession
                // If room type is Webcast1/10MinShortSession/20MinShortSession, set _sessionStartTime to the bigger one of presenter login time and normal class time.
                // Else, set _sessionStartTime to the bigger one of first student login time and presenter login time
                
                if (normalClassTime == 0 &&
                    ([sessionEvent.eventParams[2] intValue] == SessionRoomType_Webcast1 ||
                    [sessionEvent.eventParams[2] intValue] == SessionRoomType_10MinShortSession ||
                    [sessionEvent.eventParams[2] intValue] == SessionRoomType_20MinShortSession)) {
                    
                    _isLobbySession = YES;
                        
                    // Setup date formatter
                    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Taipei"];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyyMMddHHmm"];
                    [formatter setTimeZone:timeZone];
                    
                    NSString *startTimeStr = [NSString stringWithFormat:@"%@%@", [_sessionSn substringToIndex:10], _classStartMin];
                    NSDate *dateFormatted = [formatter dateFromString:startTimeStr];
                    normalClassTime = [dateFormatted timeIntervalSince1970] * 1000;
                }

                if (presenterLoginTime == 0 && [sessionEvent.eventParams[1] isEqualToString:@"1"])  // presenter
                    presenterLoginTime = sessionEvent.eventTime;
                
                if (firstStudentTime == 0 && ![sessionEvent.eventParams[1] isEqualToString:@"1"])   // not presenter
                    firstStudentTime = sessionEvent.eventTime;
                
                // 2. Set recordedSessionStream params (isPresenter, publishName, userName, startTime, enterLeaveTimeList)
                RecordedSessionStream *recordedSessionStream;
                if ([_recordedSessionStreamList objectForKey:sessionEvent.eventParams[0]]) {
                    recordedSessionStream = [_recordedSessionStreamList objectForKey:sessionEvent.eventParams[0]];
                }
                else {
                    recordedSessionStream = [RecordedSessionStream new];
                    recordedSessionStream.userName = [sessionEvent.eventParams[0] copy];
                    recordedSessionStream.publishName = [[sessionEvent.eventParams[1] isEqualToString:@"1"] ? kPresenterPublishName : sessionEvent.eventParams[0] copy];
                    recordedSessionStream.isPresenter = [sessionEvent.eventParams[1] isEqualToString:@"1"];
                    
                    _recordedSessionStreamList[sessionEvent.eventParams[0]] = recordedSessionStream;
                }
                
                if (recordedSessionStream.startTime == 0)
                    recordedSessionStream.startTime = sessionEvent.eventTime;
                [recordedSessionStream.enterLeaveTimeList addObject:@[@(sessionEvent.eventTime), @"Enter"]];
                
                break;
            }
                
            case RecordedSessionEventType_Logout:
            {
                // Ex. 1429623276350-o-Siglinde de Villiers~5255|1      (publish name|is presenter)
                if ([_recordedSessionStreamList objectForKey:sessionEvent.eventParams[0]])
                    [((RecordedSessionStream *)_recordedSessionStreamList[sessionEvent.eventParams[0]]).enterLeaveTimeList addObject:@[@(sessionEvent.eventTime), @"Leave"]];
                
                break;
            }
            
            default:
                break;
        }
        
        _sessionEndTime = sessionEvent.eventTime;
    }
    
    // Post process enter/leave time
    [self _postProcessEnterLeaveTime];
    
    DDLogDebug(@"normalClassTime: %lld, presenterLoginTime: %lld, firstStudentTime: %lld", normalClassTime, presenterLoginTime, firstStudentTime);
    if (normalClassTime != 0)
        _sessionStartTime = normalClassTime > presenterLoginTime ? normalClassTime : presenterLoginTime;
    else
        _sessionStartTime = presenterLoginTime > firstStudentTime ? presenterLoginTime : firstStudentTime;
    
    DDLogDebug(@"Parsing RecordedSessionEvents end");
}

- (void)_postProcessEnterLeaveTime {
    [self _mergeEnterLeaveTimeListOfPresentersToTheFirstOne];
    [self _removeDuplicatedEnterLeaveTime];
}

// Keep the first Enter and the last Leave if duplicated
- (void)_removeDuplicatedEnterLeaveTime {
    for (RecordedSessionStream *stream in [_recordedSessionStreamList allValues]) {
        NSString *prevAction = [stream.enterLeaveTimeList[0][1] copy];
        for (int i = 1; i < stream.enterLeaveTimeList.count; i++) {
            if ([prevAction isEqualToString:@"Enter"] && [stream.enterLeaveTimeList[i][1] isEqualToString:@"Enter"]) {
                [stream.enterLeaveTimeList removeObjectAtIndex:i];
                i--;
            }
            else if ([prevAction isEqualToString:@"Leave"] && [stream.enterLeaveTimeList[i][1] isEqualToString:@"Leave"]) {
                [stream.enterLeaveTimeList removeObjectAtIndex:i-1];
                i--;
            }
            else
                prevAction = [stream.enterLeaveTimeList[i][1] copy];
        }
    }
}

- (void)_mergeEnterLeaveTimeListOfPresentersToTheFirstOne {
    RecordedSessionStream *firstPresenter;
    for (RecordedSessionStream *stream in [_recordedSessionStreamList allValues]) {
        if (stream.isPresenter) {
            firstPresenter = stream;
            break;
        }
    }
    
    if (firstPresenter) {
        for (RecordedSessionStream *stream in [_recordedSessionStreamList allValues]) {
            if (stream.isPresenter && ![stream.userName isEqualToString:firstPresenter.userName]) {
                [firstPresenter.enterLeaveTimeList addObjectsFromArray:stream.enterLeaveTimeList];
            }
        }
    }
}

#pragma mark - Utilities
- (NSData *)_sendSyncHttpGetRequest:(NSString *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&urlResponse error:&requestError];
    
    return response;
}

#pragma mark - NSXMLParserDelegate Handler
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // Sample data:
    // <directory>
    //     <file name="01.png" type="File" size="47634" w="701" h="526"/>
    // </directory>
    
    if ([elementName isEqualToString:@"file"]) {
        RecordedSessionImageInfo *imageInfo = [[RecordedSessionImageInfo alloc] initWithName:attributeDict[@"name"]
                                                                                       width:[attributeDict[@"w"] intValue]
                                                                                      height:[attributeDict[@"h"] intValue]];
        NSString *nameStr = attributeDict[@"name"];
        NSRange point = [attributeDict[@"name"] rangeOfString:@"."];
        if (point.location != NSNotFound) {
            nameStr = [nameStr substringToIndex:point.location];
        }
        _imageInfoDict[@([nameStr intValue] - 1)] = imageInfo;
    }
}

@end
