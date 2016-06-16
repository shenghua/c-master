//
//  LogService.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/11/17.
//
//

#import "LogService.h"
#import "HttpRequestUtility.h"

@interface LogService ()
@property (nonatomic, strong) NSString *sessionSn;
@property (nonatomic, strong) NSString *userSn;
@property (nonatomic, strong) NSString *userType;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *shortUserName;  // userName without "~xxxx"
@property (nonatomic, strong) NSString *compStatus;
@end

@implementation LogService

- (instancetype)initWithSessionSn:(NSString *)sessionSn userSn:(NSString *)userSn userType:(NSString *)userType userName:(NSString *)userName compStatus:(NSString *)compStatus {
    if (self = [super init]) {
        _sessionSn = [sessionSn copy];
        _userSn = [userSn copy];
        _userType = [userType copy];
        _userName = [userName copy];
        _compStatus = [compStatus copy];
    }
    
    return  self;
}

- (void)addSessionLog:(NSString *)event content:(NSString *)content {
    NSArray *queryParams = @[@"action=addSessionLog",
                             [NSString stringWithFormat:@"sessionSn=%@", _sessionSn],
                             [NSString stringWithFormat:@"userSn=%@", _userSn],
                             [NSString stringWithFormat:@"userType=%@", _userType],
                             [NSString stringWithFormat:@"logType=%d", 1],
                             [NSString stringWithFormat:@"event=%@", event],
                             [NSString stringWithFormat:@"content=%@", content],
                             [NSString stringWithFormat:@"compStatus=%@", _compStatus]];
    
    [HttpRequestUtility sendAsyncHttpRequest:[queryParams componentsJoinedByString:@"&"] urlStr:kLogServiceUrl];
}

- (void)addChatLog:(NSString *)message {
    NSArray *queryParams = @[@"action=addChatLog",
                             [NSString stringWithFormat:@"name=%@", [self getUserNameWithoutTilde]],
                             [NSString stringWithFormat:@"sessionSn=%@", _sessionSn],
                             [NSString stringWithFormat:@"senderUserSn=%@", _userSn],
                             [NSString stringWithFormat:@"senderUserType=%@", _userType],
                             [NSString stringWithFormat:@"receiverUserSn=%d", -2],
                             [NSString stringWithFormat:@"receiverUserType=%d", 1],
                             [NSString stringWithFormat:@"msg=%@", message],
                             [NSString stringWithFormat:@"compStatus=%@", _compStatus]];
    
    [HttpRequestUtility sendAsyncHttpRequest:[queryParams componentsJoinedByString:@"&"] urlStr:kLogServiceUrl];
}

- (NSData *)addHelpMsg:(NSString *)message custSupType:(int)custSupType {
    NSArray *queryParams = @[@"action=addHelpMsg",
                             [NSString stringWithFormat:@"name=%@", [self getUserNameWithoutTilde]],
                             [NSString stringWithFormat:@"sessionSn=%@", _sessionSn],
                             [NSString stringWithFormat:@"userSn=%@", _userSn],
                             [NSString stringWithFormat:@"userType=%@", _userType],
                             [NSString stringWithFormat:@"type=%d", custSupType],
                             [NSString stringWithFormat:@"msg=%@", message],
                             [NSString stringWithFormat:@"compStatus=%@", _compStatus],
                             [NSString stringWithFormat:@"rnd=%d", arc4random_uniform(10000)]];
    
    NSData *response = [HttpRequestUtility sendSyncHttpRequest:[queryParams componentsJoinedByString:@"&"] urlStr:kLogServiceUrl];
    
    return response;
}

- (NSData *)updateConfirmHelpMsg:(NSString *)helpMsgId flag:(NSString *)flag {
    NSArray *queryParams = @[@"action=updateConfirmHelpMsg",
                             [NSString stringWithFormat:@"helpMsgId=%@", helpMsgId],
                             [NSString stringWithFormat:@"flag=%@", flag],
                             [NSString stringWithFormat:@"rnd=%d", arc4random_uniform(10000)]];
    NSData *data = [HttpRequestUtility sendSyncHttpRequest:[queryParams componentsJoinedByString:@"&"] urlStr:kLogServiceUrl];
    
    return data;
}

#pragma mark - Utitlies
- (NSString *)getUserNameWithoutTilde {
    NSString *name = _userName;
    NSRange range = [name rangeOfString:@"~"];
    if (range.location != NSNotFound)
        name = [name substringToIndex:range.location];
    
    return name;
}
@end
