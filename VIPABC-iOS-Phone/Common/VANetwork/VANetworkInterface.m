//
//  VANetworkInterface.m
//  VIPABC4Phone
//
//  Created by ledka on 15/11/30.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VANetworkInterface.h"
#import "VANetwork.h"
#import "JSONKit.h"

#define vDeviceId [[[UIDevice currentDevice] identifierForVendor] UUIDString]   //903E7E89162D4A02A075593D490AA662
#define vRelease 1

#ifdef vRelease
#define vServerApiURL @"http://open.vipabc.com/" //@"http://open.vipabc.com:8080/"
#else
#define vServerApiURL @"http://snstage.vipabc.com/greenDay/"
#endif

#define vApiLogin @"api/User/Login"
// 发送验证码
#define vSendVerificationCode @"api/Mgm/SendVerificationCode"
// 校验验证码
#define vVerificateCode @"api/Mgm/VerificateCode"
// 注册用户
#define vRegister @"api/User/Register"
// 验证邮箱手机号
#define vVerificateEmailAndMobile @"api/User/CheckEmailAndMobile"
// 获取配置信息
#define vConfigure @"api/System/Configure"
// 奖励邀请人
#define vRewardInviter @"api/Mgm/RewardInviter"
// 获取用户信息
#define vUserInfo @"api/User/Info"

@implementation VANetworkInterface

+ (void)loginWithUserName:(NSString *)userName password:(NSString *)password
{
    
}

+ (BOOL)isNetworkReachable
{
    return [VANetwork isNetworkReachable];
}

+ (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
             successBlock:(void (^)(VAUserModel *user))successBlock
              failedBlock:(VARequestFailedBlock)failedBlock
{
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                vDeviceId, @"DeviceID",
                                @"json", @"Tmpl",
                                userName, @"Account",
                                password, @"Password",
                                @"5", @"BrandID",
                                @"com.tutorabc.tutormobile", @"PkgName", nil];
    
    [VANetwork sendRequestWithURL:[NSString stringWithFormat:@"%@%@", vServerApiURL, vApiLogin] parameters:parameters successBlock:^(id responseObject) {
        DDLogVerbose(@"%@", [responseObject objectForKey:@"ErrorMessage"]);
    } failedBlock:^(NSError *error, id responseObject) {
        [responseObject JSONData];
    }];
}

+ (void)sendVerificationCodeWithMobileNo:(NSString *)mobileNo
                            successBlock:(VARequestSuccessBlock)successBlock
                             failedBlock:(VARequestFailedBlock)failedBlock
{
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                mobileNo, @"Mobile",
                                nil];
    
    [VANetwork sendRequestWithURL:[NSString stringWithFormat:@"%@%@", vServerApiURL, vSendVerificationCode] parameters:parameters successBlock:^(id responseObject) {
        DDLogDebug(@"response data: %@", responseObject);
        successBlock(responseObject);
    } failedBlock:^(NSError *error, id responseObject) {
        DDLogDebug(@"response error: %@", responseObject);
        if (responseObject == nil || [@"" isEqualToString:responseObject])
            responseObject = @"发送验证码失败！";
        failedBlock(error, responseObject);
    }];
}

+ (void)verificateCodeWithMobileNo:(NSString *)mobileNo
                              code:(NSString *)code
                      successBlock:(VARequestSuccessBlock)successBlock
                       failedBlock:(VARequestFailedBlock)failedBlock
{
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:mobileNo, @"Mobile", code, @"Code", nil];
    
    [VANetwork sendRequestWithURL:[NSString stringWithFormat:@"%@%@", vServerApiURL, vVerificateCode] parameters:parameters successBlock:^(id responseObject) {
        DDLogDebug(@"response data: %@", responseObject);
        successBlock(responseObject);
    } failedBlock:^(NSError *error, id responseObject) {
        DDLogDebug(@"response error: %@", responseObject);
        if (responseObject == nil || [@"" isEqualToString:responseObject])
            responseObject = @"验证码校验失败！";
        failedBlock(error, responseObject);
    }];
}

+ (void)registerWithName:(NSString *)name
                password:(NSString *)password
                   email:(NSString *)email
                     sex:(NSString *)sex
                  mobile:(NSString *)mobile
            successBlock:(VARequestSuccessBlock)successBlock
             failedBlock:(VARequestFailedBlock)failedBlock
{
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                            name, @"Name",
                                                        password, @"Password",
                                                           email, @"Email",
                                                             sex, @"Sex",
                                                          mobile, @"Cellphone",
                                                            nil];
    
    [VANetwork sendRequestWithURL:[NSString stringWithFormat:@"%@%@", vServerApiURL, vRegister] parameters:parameters successBlock:^(id responseObject) {
        DDLogDebug(@"response data: %@", responseObject);
        successBlock(responseObject);
    } failedBlock:^(NSError *error, id responseObject) {
        DDLogDebug(@"response error: %@", responseObject);
        if (responseObject == nil || [@"" isEqualToString:responseObject])
            responseObject = @"注册失败！";
        failedBlock(error, responseObject);
    }];
}

+ (void)checkEmail:(NSString *)email
            mobile:(NSString *)mobile
      successBlock:(VARequestSuccessBlock)successBlock
       failedBlock:(VARequestFailedBlock)failedBlock
{
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                            email, @"Email",
                                                            mobile, @"Mobile", nil];
    [VANetwork sendRequestWithURL:[NSString stringWithFormat:@"%@%@", vServerApiURL, vVerificateEmailAndMobile] parameters:parameters successBlock:^(id responseObject) {
        successBlock(responseObject);
    } failedBlock:^(NSError *error, id responseObject) {
        if (responseObject == nil || [@"" isEqualToString:responseObject])
            responseObject = @"注册失败！";
        failedBlock(error, responseObject);
    }];
}

+ (void)fetchConfigureWithVersion:(NSString *)version
                          appName:(NSString *)appName
                         platForm:(NSString *)platForm
                       deviceType:(NSString *)deviceType
                         language:(NSString *)language
                     successBlock:(VARequestSuccessBlock)successBlock
                      failedBlock:(VARequestFailedBlock)failedBlock
{
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            version, @"Version",
                                            appName, @"AppName",
                                            platForm, @"platForm",
                                            deviceType, @"deviceType",
                                            language, @"language", nil];
    
    [VANetwork sendRequestWithURL:[NSString stringWithFormat:@"%@%@", vServerApiURL, vConfigure] parameters:parameters successBlock:^(id responseObject) {
        successBlock(responseObject);
    } failedBlock:^(NSError *error, id responseObject) {
        if (responseObject == nil || [@"" isEqualToString:responseObject])
            responseObject = @"";
        failedBlock(error, responseObject);
    }];
}

+ (void)rewardInviterWithClientSn:(NSString *)clientSn
                     successBlock:(VARequestSuccessBlock)successBlock
                      failedBlock:(VARequestFailedBlock)failedBlock
{
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                clientSn, @"ClientSn", nil];
    
    [VANetwork sendRequestWithURL:[NSString stringWithFormat:@"%@%@", vServerApiURL, vRewardInviter] parameters:parameters successBlock:^(id responseObject) {
        successBlock(responseObject);
    } failedBlock:^(NSError *error, id responseObject) {
        if (responseObject == nil || [@"" isEqualToString:responseObject])
            responseObject = @"";
        failedBlock(error, responseObject);
    }];
}

+ (void)fetchUserInfo:(NSString *)clientSn
         successBlock:(VARequestSuccessBlock)successBlock
          failedBlock:(VARequestFailedBlock)failedBlock
{
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                clientSn, @"ClientSn", nil];
    
    [VANetwork sendRequestWithURL:[NSString stringWithFormat:@"%@%@", vServerApiURL, vUserInfo] parameters:parameters successBlock:^(id responseObject) {
        successBlock(responseObject);
    } failedBlock:^(NSError *error, id responseObject) {
        if (responseObject == nil || [@"" isEqualToString:responseObject])
            responseObject = @"";
        failedBlock(error, responseObject);
    }];
}
@end
