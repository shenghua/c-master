//
//  VANetwork.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/23.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VANetwork.h"

@implementation VANetwork

+ (instancetype)shareInstance
{
    static VANetwork *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[VANetwork alloc] init];
    });
    
    return instance;
}

+ (void)sendRequestWithURL:(NSString *)url
                parameters:(NSDictionary *)parameters
              successBlock:(VARequestSuccessBlock)successBlock
               failedBlock:(VARequestFailedBlock)failedBlock
{
    if ([VANetwork isNetworkReachable]) {
        VANetwork *network = [[VANetwork alloc] init];
        
        [network POST:url parameters:parameters
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
               if ([[responseObject objectForKey:@"Status"] isEqualToString:@"OK"])
                   successBlock(responseObject);
               else {
                   failedBlock([responseObject objectForKey:@"ErrCode"], [responseObject objectForKey:@"ErrorMessage"]);
               }
           }
           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               failedBlock(error, @"");
           }];
    } else {
        NSError *error = [NSError errorWithDomain:@"" code:100 userInfo:nil];
        failedBlock(error, @"请检查您的网络设置！");
    }
}

+ (BOOL)isNetworkReachable
{
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

@end
