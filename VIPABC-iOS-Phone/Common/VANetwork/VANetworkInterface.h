//
//  VANetworkInterface.h
//  VIPABC4Phone
//
//  Created by ledka on 15/11/30.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAUserModel.h"

@interface VANetworkInterface : NSObject

+ (BOOL)isNetworkReachable;

+ (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
             successBlock:(void (^)(VAUserModel *user))successBlock
              failedBlock:(VARequestFailedBlock)failedBlock;

+ (void)sendVerificationCodeWithMobileNo:(NSString *)mobileNo
                            successBlock:(VARequestSuccessBlock)successBlock
                             failedBlock:(VARequestFailedBlock)failedBlock;

+ (void)verificateCodeWithMobileNo:(NSString *)mobileNo
                              code:(NSString *)code
                      successBlock:(VARequestSuccessBlock)successBlock
                       failedBlock:(VARequestFailedBlock)failedBlock;

+ (void)registerWithName:(NSString *)name
                password:(NSString *)password
                   email:(NSString *)email
                     sex:(NSString *)sex
                  mobile:(NSString *)mobile
            successBlock:(VARequestSuccessBlock)successBlock
             failedBlock:(VARequestFailedBlock)failedBlock;

+ (void)checkEmail:(NSString *)email
            mobile:(NSString *)mobile
      successBlock:(VARequestSuccessBlock)successBlock
       failedBlock:(VARequestFailedBlock)failedBlock;

+ (void)fetchConfigureWithVersion:(NSString *)version
                          appName:(NSString *)appName
                         platForm:(NSString *)platForm
                       deviceType:(NSString *)deviceType
                         language:(NSString *)language
                     successBlock:(VARequestSuccessBlock)successBlock
                      failedBlock:(VARequestFailedBlock)failedBlock;

+ (void)rewardInviterWithClientSn:(NSString *)clientSn
                     successBlock:(VARequestSuccessBlock)successBlock
                      failedBlock:(VARequestFailedBlock)failedBlock;

+ (void)fetchUserInfo:(NSString *)clientSn
         successBlock:(VARequestSuccessBlock)successBlock
          failedBlock:(VARequestFailedBlock)failedBlock;
@end
