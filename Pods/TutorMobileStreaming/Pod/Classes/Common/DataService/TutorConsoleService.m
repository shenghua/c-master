//
//  TutorConsoleService.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/2.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "TutorConsoleService.h"
#import "TutorLog.h"

@interface TutorConsoleService()
@property (nonatomic, weak) id<TutorConsoleServiceDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *msgIdDict;
@end

@implementation TutorConsoleService

- (id)initWithUrl:(NSString *)url delegate:(id<TutorConsoleServiceDelegate>)delegate userParams:(NSDictionary *)userParams {
    if (self = [super initWithUrl:url userParams:userParams]) {
        _msgIdDict = [NSMutableDictionary new];
        _delegate = delegate;
    }
    return self;
}

#pragma mark - librtmp Callback Handler
- (void)rtmpCallback:(RtmpCallbackType)cbType userData:(void *)userData cbData:(void *)cbData {
    switch (cbType) {
        case RtmpCallbackType_Connected:
            DDLogDebug(@"RtmpCallbackType_Connected");
            [(__bridge TutorConsoleService *)userData _executePostConnectedTasks];
            break;
            
        default:
            DDLogDebug(@"Unknown callback type: %d", cbType);
            break;
    }
}

- (void)_executePostConnectedTasks {
    // Connect shared object
    [self connectSharedObject:kUsersSo flag:0];
}

#pragma mark - Chat Handler
- (NSString *)_getMsgId:(NSString *)message custSupType:(int)custSupType {
    NSData *response = [self.logService addHelpMsg:message custSupType:custSupType];
    
    if (response) {
        NSError *errorJson = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&errorJson];
        
        if (responseDict) {
            if (responseDict[@"status"] && [responseDict[@"status"] isEqualToString:@"0"]) {
                NSString *code = responseDict[@"code"];
                if (code) {
                    NSRange rangeMsgId = [code rangeOfString:@"|"];
                    if (rangeMsgId.location != NSNotFound)
                        return [code substringToIndex:rangeMsgId.location];
                }
            }
        }
    }
    
    return nil;
}

- (void)sendHelpMessage:(NSString *)message
        custSupMsgIndex:(int)custSupMsgIndex
            custSupType:(int)custSupType {
    
    NSString *msgId= [self _getMsgId:message custSupType:custSupType];
    
    if (msgId) {
        // Add to message id map
        if (!_msgIdDict[msgId]) {
            _msgIdDict[msgId] = @[message, @(custSupMsgIndex)];
        }
        
        // Invoke RTMP command
        CustSuptMsg *custSuptMsg = malloc(sizeof(CustSuptMsg));
        strncpy(custSuptMsg->msg, [message cStringUsingEncoding:NSUTF8StringEncoding], 1024);
        strncpy(custSuptMsg->custSuptLabel, [@"" cStringUsingEncoding:NSUTF8StringEncoding], 50);
        strncpy(custSuptMsg->custSuptReceiver, [@"CustSupt" cStringUsingEncoding:NSUTF8StringEncoding], 50);
        strncpy(custSuptMsg->custSuptReceiverLabel, [@"IT" cStringUsingEncoding:NSUTF8StringEncoding], 50);
        strncpy(custSuptMsg->currentClassRoom, [[NSString stringWithFormat:@"%@_%@", self.userParams[@"sessionRoomId"], self.userParams[@"sessionSn"]] cStringUsingEncoding:NSUTF8StringEncoding], 50);
        custSuptMsg->custSupChat = 1;
        custSuptMsg->custSupType = custSupType;
        custSuptMsg->custSupMsgIndex = custSupMsgIndex;
        strncpy(custSuptMsg->custSuptNewMsgId, [msgId cStringUsingEncoding:NSUTF8StringEncoding], 20);
        strncpy(custSuptMsg->clientStatus, [@"" cStringUsingEncoding:NSUTF8StringEncoding], 10);
        strncpy(custSuptMsg->compStatusLogo, [self.userParams[@"compStatus"] cStringUsingEncoding:NSUTF8StringEncoding], 10);
        
        [self invokeCmd:RtmpCmd_TalkToCustSupt params:(void *)custSuptMsg];
        
        free(custSuptMsg);
        
        // Callback waiting status
        if (_delegate && [_delegate respondsToSelector:@selector(onHelpMessage:msgIdx:status:)]) {
            [_delegate onHelpMessage:msgId msgIdx:custSupMsgIndex status:HelpMsgStatus_Waiting];
        }
    }
}

- (void)confirmHelpMsg:(NSString *)msgId confirmed:(HelpMsgConfirmed)confirmed {
    if (confirmed == HelpMsgConfirmed_No) {
        NSArray *msg = _msgIdDict[msgId];
        [self sendHelpMessage:msg[0] custSupMsgIndex:[msg[1] intValue] custSupType:HelpMsgType_NotSatisfied];
    } else {
        [_msgIdDict removeObjectForKey:msgId];
    }
    
    NSString *flag = [self _helpMsgConfirmedToFlag:confirmed];

    NSData *data = [self.logService updateConfirmHelpMsg:msgId flag:flag];    
}

#pragma mark - Utilities
- (NSString *)_helpMsgConfirmedToFlag:(HelpMsgConfirmed)confirmed {
    switch (confirmed) {
        case HelpMsgConfirmed_Yes:
            return @"Y";
            
        case HelpMsgConfirmed_Accept:
            return @"A";
            
        case HelpMsgConfirmed_No:
            return @"N";
    }
    
    return nil;
}

@end
