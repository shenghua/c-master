//
//  LogService.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/11/17.
//
//

#import <Foundation/Foundation.h>
#define kLogServiceUrl @"http://www.tutormeet.com/tutormeetweb/log.do"

@interface LogService : NSObject

- (instancetype)initWithSessionSn:(NSString *)sessionSn
                           userSn:(NSString *)userSn
                         userType:(NSString *)userType
                         userName:(NSString *)userName
                       compStatus:(NSString *)compStatus;
- (void)addSessionLog:(NSString *)event content:(NSString *)content;
- (void)addChatLog:(NSString *)message;
- (NSData *)addHelpMsg:(NSString *)message custSupType:(int)custSupType;
- (NSData *)updateConfirmHelpMsg:(NSString *)helpMsgId flag:(NSString *)flag;
@end
