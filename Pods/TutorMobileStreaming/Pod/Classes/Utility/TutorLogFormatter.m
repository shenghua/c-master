//
//  TutorLogFormatter.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/7/7.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "TutorLogFormatter.h"

@interface TutorLogFormatter()
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation TutorLogFormatter

- (id)init {
    if (self = [super init]) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    return [NSString stringWithFormat:@"%@ %@[%d:%@][%@] %@", [_formatter stringFromDate:logMessage->_timestamp],
                                                             [[NSProcessInfo processInfo] processName],
                                                             (int)getpid(),
                                                             logMessage->_threadID,
                                                             logMessage->_fileName,
                                                             logMessage->_message];
}

@end
