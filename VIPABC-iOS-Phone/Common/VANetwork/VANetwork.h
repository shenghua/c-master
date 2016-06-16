//
//  VANetwork.h
//  VIPABC4Phone
//
//  Created by ledka on 15/11/23.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "VAConstants.h"

@interface VANetwork : AFHTTPSessionManager

+ (instancetype)shareInstance;

+ (BOOL)isNetworkReachable;

+ (void)sendRequestWithURL:(NSString *)url
                parameters:(NSDictionary *)parameters
              successBlock:(VARequestSuccessBlock)successBlock
               failedBlock:(VARequestFailedBlock)failedBlock;

@end
