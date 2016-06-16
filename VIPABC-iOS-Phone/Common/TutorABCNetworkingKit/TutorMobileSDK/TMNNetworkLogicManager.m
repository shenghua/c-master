//
//  TMNNetworkLogicManager.m
//  TutorMobileSDK
//
//  Created by Eddy Tsai_蔡佳翰 on 2015/12/31.
//  Copyright © 2015年 Eddy. All rights reserved.
//

#import "TMNNetworkLogicManager.h"
@implementation TMNNetworkLogicManager

+ (TMNNetworkLogicController *)sharedInstace {
//    NSString *defaultHost = @"http://192.168.23.109:8018";//http://mobapi.vipabc.com
    NSString *defaultHost = @"http://mobapi.vipabc.com";
//    NSString *defaultHost = @"http://vipabc.mobcommon.com";
    
    static TMNNetworkLogicController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedManager = [[TMNNetworkLogicController alloc] initWithUrlHost:defaultHost];
    });
    return _sharedManager;
}

@end
