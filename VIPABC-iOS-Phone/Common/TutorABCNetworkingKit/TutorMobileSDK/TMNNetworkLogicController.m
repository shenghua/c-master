//
//  TMNNetworkLogicController.m
//  TutorMobileNative
//
//  Created by Oxy Hsing_邢傑 on 8/31/15.
//  Copyright (c) 2015 TutorABC, Inc. All rights reserved.
//

#import "TMNNetworkLogicController.h"
#import "TMClassInfo.h"
#import "TMMaterial.h"
#import "NSDate+TM.h"
#import "TMConsultant.h"
#import "AFNetworking.h"
#import "TMResponse.h"
#import "MJExtension.h"
#import "TMLesson.h"
#import "TMConsultant.h"
#import <UIKit/UIKit.h>
#import "ErrorCodeFromAPI.h"
#import "TMPlanLessonUtil.h"
#import "TMContractUtil.h"
#import "TMNAppInfoUtil.h"
#import "TMConfigUtil.h"
#import "TMReserveLessonUtil.h"
#import "TMEnterClassInfo.h"
#import "TMRoomInfo.h"
#import "LocalizedString.h"
#import "TMNextSessionInfo.h"
#import "TMNConstantObj.h"
#import "TMClassUtil.h"
#import "Device.h"
#import "VATool.h"


#define kDeviceID ([[[UIDevice currentDevice] identifierForVendor] UUIDString])
#define kLessonCanceledNotification @"onLessonCanceled"
#define kCurrentUserKey @"currentUser"
#define kBrand TMNBrandID_VIPABC


// use stage host by
#ifdef HOST_STAGE
    #define APIURL @"http://192.168.23.109:8018"
#else
    #define APIURL @"http://mobapi.tutorabc.com"
#endif


@interface TMNNetworkLogicController ()
@property (nonatomic, strong) NSString *urlHost;
@property (nonatomic, strong) NSString *deviceId;
@end

@implementation TMNNetworkLogicController (responseChecking)


- (void)checkObject:(id)object
  successBlock:(TMNNetworkSuccessDicBlock)successBlock
     failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    NSError *error = [NSError errorWithDomain:STR_ERROR_DOMAIN
                                         code:[[[object objectForKey:@"status"] objectForKey:@"code"] integerValue]
                                     userInfo:@{NSLocalizedDescriptionKey: [[object objectForKey:@"status"] objectForKey:@"code"]}];
    switch ([[[object objectForKey:@"status"] objectForKey:@"code"] integerValue]) {
        case 100013:
//            if (failedBlock) { failedBlock(error, STR_TOKEN_EXPIRED); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100013"]); }
            break;
        case 100000:
            if (successBlock) { successBlock([object objectForKey:@"data"]); }
            break;
        case 100006:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100006"]); }
            break;
        case 100007:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100007"]); }
            break;
        case 100008:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100008"]); }
            break;
        case 100009:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100009"]); }
            break;
        case 100010:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100010"]); }
            break;
        case 100012:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100012"]); }
            break;
        case 100101:
//            if (failedBlock) { failedBlock(error, STR_LOGIN_FAIL); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100101"]); }
             break;
        case 100102:
//            if (failedBlock) { failedBlock(error, STR_LOGIN_FAIL_CAN_NOT_GET_USER_ACCOUNT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100102"]); }
        case 100202:
//            if (successBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100202"]); }
            break;
        case 100203:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100203"]); }
            break;
        case 100204:
//            if (failedBlock) { failedBlock(error, STR_NOGOTOGLASS_CONTENT_POWERSESSION); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100204"]); }
            break;
        case 100205:
//            if (failedBlock) { failedBlock(error, STR_ENTER_SESSION_WITHOUT_CHECKIN); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100205"]); }
            break;
        case 100206:
//            if (failedBlock) { failedBlock(error, STR_ENTER_SESSION_JoinNet); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100206"]); }
            break;
        case 100301:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100301"]); }
            break;
        case 100501:
//            if (failedBlock) { failedBlock(error, STR_ERROR_RATING_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100501"]); }
            break;
        case 100601:
//            if (failedBlock) { failedBlock(error, STR_ERROR_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100601"]); }
            break;
        default:
//            if (failedBlock) { failedBlock(error, STR_ERRORGOTOGLASS_CONTENT); }
            if (failedBlock) { failedBlock(error, [VATool fetchMessageWithCode:@"100001"]); }
            break;
    }
}


@end

@implementation TMNNetworkLogicController

- (TMUser *) currentUser{
    TMUser *user = [TMUser objectWithKeyValues:[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey]];
    return user;
}


+ (instancetype)sharedInstance {
    TMNNetworkLogicController *instance = [[TMNNetworkLogicController alloc] initWithUrlHost:@""];
    return instance;
}

- (instancetype)initWithUrlHost:(NSString *)host {
    self = [super init];
    
    if (self) {
        NSURL *candidateURL = [NSURL URLWithString:host];
        if (candidateURL && candidateURL.scheme && candidateURL.host) {
            self.urlHost = host;
        } else {
            //    NSString *defaultHost = @"http://192.168.23.109:8018";//http://mobapi.vipabc.com
            NSString *defaultHost = @"http://mobapi.vipabc.com";
            self.urlHost = defaultHost;
        }
        
//        self.deviceId = @"";
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithString:self.urlHost];
        Device *device = [Device sharedDeviceWithHost:urlComponents.host port:@"80" scheme:@"http"];
        self.deviceId = device.deviceId;
        if (urlComponents.host) {
            
            [device registerWithBrandId:NSStringFromInteger(TMNBrandID_VIPABC)
                             completion:^(id data, NSError *err) {
                                 self.deviceId = [data objectForKey:@"deviceId"];
                                 NSLog(@"[device id updated] data:\n%@,\nerr:\n%@", data, err);
                             }];
        }
        
    }
    return self;
}

#pragma mark - SDK initialize

- (NSString *)getDeviceId {
    return self.deviceId;
}

// version checking, isReview mode checking
- (void) getTrackStarterWithBrandId:(TMNBrandID)brandId
                            version:(NSString *)version
                       successBlock:(TMNNetworkSuccessDicBlock)successBlock
                        failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"tmpl":@"json",
                                                              @"brandId":@(brandId),
                                                              @"version":version,
                                                              @"platform":@(0)}];
    params[@"deviceId"] = self.deviceId;
    NSLog(@"params: %@", params);
    NSLog(@"API url:%@", self.urlHost);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:[NSString stringWithFormat:@"%@/mobcommon/webapi/track/1/start",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"resp: %@", responseObject);
        [self checkObject:responseObject
             successBlock:successBlock
              failedBlock:failedBlock];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err: %@", error);
        failedBlock(error, nil);
    }];
}

#pragma mark - login, logout

- (void) getConfigWithSuccessBlock:(TMNNetworkSuccessObjectBlock)successBlock
                       failedBlock:(TMNNetworkFailedBlock)failedBlock{
    
    
    TMUser *user = [self currentUser];
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"token":user.token,
                                                              @"deviceId":user.deviceID,
                                                              @"brandId":@(kBrand),
                                                              @"platform":@(0),
                                                              @"sdkVer":@"1.0",
                                                              @"locale":@"zh-TW"}];
    
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/config/1/getConfig",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        
        if(response && response.status.code == 100000){
            
            TMConfig *config = [TMConfig objectWithKeyValues:response.data];
            successBlock(config);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
           
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
    
}

- (void) loginWithAccount:(NSString *) account
                     password:(NSString *) password
                      brandId:(TMNBrandID) brandId
                 successBlock:(TMNNetworkSuccessObjectBlock) successBlock
                  failedBlock:(TMNNetworkFailedBlock) failedBlock{
    
    if(!self.deviceId){
        self.deviceId = @"iOS_Device";
    }
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"deviceId":self.deviceId,@"account":account,@"pkgName":@"",@"password":password,@"brandId":@(brandId)}];
   

    
    [[AFHTTPRequestOperationManager manager] POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/user/1/login?",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        
        if(response && response.status.code == 100000){
           
            TMUser *user = [TMUser objectWithKeyValues:response.data];
            
            [[NSUserDefaults standardUserDefaults] setObject:user.keyValues forKey:kCurrentUserKey];

            [[TMContractUtil sharedUtil] syncContractsWithResultBlock:^(NSError *error, NSArray *contracts, NSDictionary *contractsDict) {

                if (!error) {
                    
                    // 被isInService == true濾到剩下有在期合約
                    if (contracts && [contracts count] > 0) {
                        user.isInService = YES;
                    } else {
                        // 非在期合約
                        user.isInService = NO;
                    }
                    
                    user.deviceID = self.deviceId;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:user.keyValues forKey:kCurrentUserKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[TMConfigUtil sharedUtil] syncWithBlock:nil];
                    [[TMPlanLessonUtil sharedUtil] clean];
                    [[TMPlanLessonUtil sharedUtil] syncLessonsWithResultBlock:nil];
                    [[TMReserveLessonUtil sharedUtil] clearLessons];
                    [[TMClassUtil sharedUtil] clean];
                    
                    successBlock(user);
                } else {
                    failedBlock(error, nil);
                }
            }];
        }else{
            
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUserKey];
        
        failedBlock(error,nil);
    }];
}

- (void) getVocWithMaterialSn:(NSString * ) materialSn
                     clientSn:(NSString *) clientSn
                     language:(NSString *) language
                    wordCount:(int) wordCount
                        scope:(int) scope
                      brandId:(TMNBrandID) brandId
                 successBlock:(TMNNetworkSuccessArrayBlock) successBlock
                  failedBlock:(TMNNetworkFailedBlock) failedBlock {
    
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"materialSn":materialSn,@"tmpl":@"json",@"clientSn":clientSn,@"language":language,@"wordCount":[NSNumber numberWithInt:wordCount],@"scope":[NSNumber numberWithInt:scope],@"brandId":@(brandId)}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
   
    [manager GET:[NSString stringWithFormat:@"%@/mobcommon/webapi/vocabulary/1/preview",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            successBlock(responseObject);
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failedBlock(error,nil);
    }];
    

}
- (void) getClassInfoWithSn:(NSString *) sessionSn
                     successBlock:(TMNNetworkSuccessObjectBlock) successBlock
                      failedBlock:(TMNNetworkFailedBlock) failedBlock{
    
    TMUser *currentUser = [self currentUser];
    
    if(!currentUser || !currentUser.token || !currentUser.clientSn){
        failedBlock([NSError errorWithDomain:@"current user is not found" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"tmpl":@"json",@"sessionSn":sessionSn,@"token":currentUser.token,@"clientSn":currentUser.clientSn,@"brandId":@(kBrand)}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/getsessioninfobysessionsn",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            TMClassInfo *classinfo;
            
            if(response.data && response.data.count>0){
                classinfo = [TMClassInfo objectWithKeyValues:response.data[0]];
                successBlock(classinfo);
            }else{
                NSError *error = [NSError errorWithDomain:STR_ERROR_DOMAIN
                                                     code:kInAPPErrorCode
                                                 userInfo:@{NSLocalizedDescriptionKey: @"DATA is EMPTY"}];
                failedBlock(error, STR_ERRORGOTOGLASS_CONTENT);
            }
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];

}

/**
 *  取得免費課程類別清單
 *
 *  @param session      <#session description#>
 *  @param brandId      品牌id(品牌如TutorABC, VIPABC, TJR, VJR)
 *  @param successBlock <#successBlock description#>
 *  @param failedBlock  <#failedBlock description#>
 */
- (void)getFreeSessionCategoryWithBrandId:(TMNBrandID)brandId
                             successBlock:(TMNNetworkSuccessDicBlock)successBlock
                              failedBlock:(TMNNetworkFailedBlock)failedBlock {
    CGFloat scale = [[UIScreen mainScreen] scale];
    NSString *scaleStr = [NSString stringWithFormat:@"%g", scale];
    // platform 0 = iOS
    NSDictionary *params = @{@"tmpl": @"json", @"brandId": @([TMNAppInfoUtil brandIDForApp]), @"ratio": scaleStr, @"platform": @(0)};
    
    //NSLog(@"----getFreeSessionCategoryWithTMNSession:brandId:successBlock:failedBlock:, url=http://mobapi.tutorabc.com/mobcommon/webapi/freesession/1/getFreeVideoCategory?tmpl=json&brandId=%@&ratio=%@", @(brandId), scaleStr);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/freesession/1/getFreeVideoCategory",self.urlHost] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
              if(response && response.status.code == 100000){
                  
                  successBlock(responseObject);
              }else{
                  [self checkObject:responseObject
                       successBlock:nil
                        failedBlock:failedBlock];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failedBlock(error, nil);
          }];
}

- (void)getFreeSessionListWithBrandId:(TMNBrandID)brandId
                            categoryIndex:(int)categoryIndex
                                 successBlock:(TMNNetworkSuccessDicBlock)successBlock
                                  failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    // 預設未登入
    TMNUserType userType = TMNUserType_NotLogin;
    
    TMUser *currentUser = [self currentUser];
    if (currentUser) {
        // 登入在期
        if (currentUser.isInService) {
            userType = TMNUserType_ContractMember;
            
        } else {
            // 登入非在期
            userType = TMNUserType_NonContractMember;
        }
    }
    
    NSDictionary *params = @{@"tmpl": @"json", @"brandId": @([TMNAppInfoUtil brandIDForApp]), @"category": @(categoryIndex), @"userType": @(userType)};
    
    //NSLog(@"----getFreeSessionListWithTMNSession:brandId:categoryIndex:successBlock:failedBlock:, url=http://mobapi.tutorabc.com/mobcommon/webapi/freesession/1/getFreeVideoList?tmpl=json&brandId=%@&category=%@&userType=%@", @(brandId), @(categoryIndex), @(userType));
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/freesession/1/getFreeVideoList",self.urlHost] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
              if(response && response.status.code == 100000){
                  
                  successBlock(responseObject);
              }else{
                  [self checkObject:responseObject
                       successBlock:nil
                        failedBlock:failedBlock];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failedBlock(error, nil);
          }];
}

- (void)getFreeSessionRecordInfoWithBrandId:(TMNBrandID)brandId
                                   fileName:(NSString *)fileName
                               successBlock:(TMNNetworkSuccessDicBlock)successBlock
                                failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    // TODO: compStatus=abc先hard, clientSn是否要從local 儲存取？
    NSString *clientSn = @"";
    NSDictionary *params = @{@"tmpl": @"json", @"fileName": fileName, @"clientSn": clientSn, @"brandId": @([TMNAppInfoUtil brandIDForApp])};
    
    //NSLog(@"----getFreeSessionRecordInfoWithTMNSession:brandId:fileName:successBlock:failedBlock:, url=http://mobapi.tutorabc.com/mobcommon/webapi/freesession/1/getDetail?tmpl=json&fileName=%@&clientSn=%@&brandId=%@", fileName, clientSn, @(brandId));
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/freesession/1/getDetail",self.urlHost] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
              if(response && response.status.code == 100000){
                  
                  successBlock(responseObject);
              }else{
                  [self checkObject:responseObject
                       successBlock:nil
                        failedBlock:failedBlock];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failedBlock(error, nil);
          }];
}

- (void)getVocabularyListWithBrandId:(TMNBrandID)brandId
                          materialSn:(NSString *)materialSn
                        successBlock:(TMNNetworkSuccessDicBlock)successBlock
                         failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    NSDictionary *params = @{@"tmpl": @"json", @"brandId": @([TMNAppInfoUtil brandIDForApp]), @"clientSn": [self currentUser].clientSn, @"materialSn": materialSn, @"token":[self currentUser].token};
    //NSLog(@"----getVocabularyListWithTMNSession:brandId:materialSn:successBlock:failedBlock:, url=http://mobapi.tutorabc.com/mobcommon/webapi/vocabulary/1/preview?tmpl=json&brandId=%@&clientSn=%@&materialSn=%@&token=%@", @(brandId), @"657698", materialSn, @"xxxcccvv");
    
    NSLog(@"------self.urlHost=%@", self.urlHost);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@/mobcommon/webapi/vocabulary/1/preview",self.urlHost] parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
              if(response && response.status.code == 100000){
                  
                  successBlock(responseObject);
              }else{
                  [self checkObject:responseObject
                       successBlock:nil
                        failedBlock:failedBlock];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failedBlock(error, nil);
          }];
}

- (void)sendDeviceTestErrReasonForStatus:(TMNTestDeviceResult)resultStatus
                         osVersion:(NSString *)osVersion
                            successBlock:(TMNNetworkSuccessDicBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    TMUser *currentUser = [self currentUser];
    NSString *clientSn = currentUser.clientSn;
    NSString *token = currentUser.token;
    NSString *osStr = [TMNAppInfoUtil platformVersionFromSystemVersion:osVersion];
    NSString *mobileVersion = [TMNAppInfoUtil appVersionString];
    
    // 預設未完成狀態
    // 2:測試失敗; 4:未完成
    int testStatus = 4;
    // 1:未完成; 2:沒有聲音
    int headsetReason = 1;
    // 1:未完成; 2:沒有聲音
    int micReason = 1;
    
    // 若是測試失敗情況
    if (resultStatus == TMNTestDeviceResult_Fail) {
        testStatus = 2;
        headsetReason = 2;
        micReason = 2;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"clientSn":clientSn, @"brandId":@(TMNBrandID_TutorABC), @"testStatus":@(testStatus), @"headsetReason":@(headsetReason), @"micReason":@(micReason), @"os":osStr, @"mobileVersion":mobileVersion  , @"token":token}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/envTest/1/testErrReason",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [self checkObject:responseObject
             successBlock:successBlock
              failedBlock:failedBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failedBlock) {
            failedBlock(error, nil);
        }
    }];
    
}

- (void)sendDeviceTestSuccessWithHeadsetVol:(int)headsetVol
                                     micVol:(int)micVol
                                  osVersion:(NSString *)osVersion
                            successBlock:(TMNNetworkSuccessDicBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    TMUser *currentUser = [self currentUser];
    NSString *clientSn = currentUser.clientSn;
    NSString *token = currentUser.token;
    NSString *osStr = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
    NSString *mobileVersion = [TMNAppInfoUtil appVersionString];
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"clientSn":clientSn, @"brandId":@(TMNBrandID_TutorABC), @"headsetVol":@(headsetVol), @"micVol":@(micVol), @"os":osStr, @"mobileVersion":mobileVersion  , @"token":token}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/envTest/1/testPass",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [self checkObject:responseObject
             successBlock:successBlock
              failedBlock:failedBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failedBlock) {
            failedBlock(error, nil);
        }
    }];
    
}

- (void)getLearningHistoryYearAndMonthWithPage:(int)page
                           recordCount:(int)recordCount
                          successBlock:(TMNNetworkSuccessDicBlock)successBlock
                           failedBlock:(TMNNetworkFailedBlock)failedBlock {
    

    
    TMUser *user = [self currentUser];
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"tmpl" : @"json",
                                                              @"clientSn" : @([user.clientSn intValue]),
                                                              @"brandId" : @(TMNBrandID_TutorABC),
                                                              @"page" : @(page),
                                                              @"recordCount" : @(recordCount),
                                                              @"token":user.token}];
    if (page == 0 || recordCount == 0) {
        [params removeObjectForKey:@"page"];
        [params removeObjectForKey:@"recordCount"];
    }
    
    params[@"deviceId"] = user.deviceID;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/getclientAttendListDate",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // NSLog(@"resp: %@", responseObject);
        [self checkObject:responseObject
             successBlock:successBlock
              failedBlock:failedBlock];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err: %@", error);
        failedBlock(error, nil);
    }];
    
}

- (void)getTimeTblWithClientSn:(NSString *)clientSn
                       brandId:(TMNBrandID)brandId
                   sessionType:(TMNClassSessionType)sessionType
                     beginTime:(long long)beginTime
                       endTime:(long long)endTime
                  successBlock:(TMNNetworkSuccessArrayBlock)successBlock
                   failedBlock:(TMNNetworkFailedBlock)failedBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"token":[self currentUser].token,@"clientSn":clientSn,@"brandId":@(brandId),@"sessionType":@(sessionType),@"beginTime":@(beginTime),@"endTime":@(endTime)}];


    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/getTimeTbl",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {

        [Classdetail setupReplacedKeyFromPropertyName:^NSDictionary *{
            return @{@"desc" : @"description"};
        }];
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            successBlock([TMLesson objectArrayWithKeyValuesArray:response.data]);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        failedBlock(error, nil);
    }];
    
}

- (void)getNextSession:(long long)beginTime
          successBlock:(TMNNetworkSuccessObjectBlock)successBlock
           failedBlock:(TMNNetworkFailedBlock)failedBlock{
    
    TMUser *currentUser = [self currentUser];
    NSString *clientSn = currentUser.clientSn;
    NSString *token = currentUser.token;

    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"token":token,@"clientSn":clientSn, @"brandId":@(TMNBrandID_TutorABC),@"beginTime":@(beginTime)}];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/getnextsession",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            TMNextSessionInfo *info = [TMNextSessionInfo objectWithKeyValues:response.data[0]];
            successBlock(info);
            
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
}

- (void)getPlanWithBeginTime:(long long)beginTime
                     endTime:(long long)endTime
                successBlock:(TMNNetworkSuccessArrayBlock)successBlock
                 failedBlock:(TMNNetworkFailedBlock)failedBlock{
    
    TMUser *currentUser = [self currentUser];
    
    if(!currentUser || !currentUser.token || !currentUser.clientSn){
        failedBlock([NSError errorWithDomain:@"current user is not found" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"token":currentUser.token,@"clientSn":currentUser.clientSn,@"brandId":@(kBrand),@"beginTime":@(beginTime),@"endTime":@(endTime)}];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/getplan",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            NSMutableArray *lessonArray = [NSMutableArray array];
            
            for (TMPlanDummyLesson *dummy in [TMPlanDummyLesson objectArrayWithKeyValuesArray:response.data]) {
                [lessonArray addObject:[TMLesson lessonWithPlanDummyLesson:dummy]];
            }
            
            successBlock(lessonArray);
            
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
    
}

- (void)getContractInfoWithSuccessBlock:(TMNNetworkSuccessArrayBlock)successBlock
                            failedBlock:(TMNNetworkFailedBlock)failedBlock{
    
    TMUser *currentUser = [self currentUser];
    
    if(!currentUser || !currentUser.token || !currentUser.clientSn){
        failedBlock([NSError errorWithDomain:@"current user is not found" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"clientSn":currentUser.clientSn,@"brandId":@(TMNBrandID_VIPABC),@"token":currentUser.token}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/contract/1/getcontractinfo",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];

        if(response && response.status.code == 100000){
            successBlock([TMContract objectArrayWithKeyValuesArray:response.data]);
            return;
        }
        [self checkObject:responseObject
             successBlock:nil
              failedBlock:failedBlock];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
    
}

- (void)getEnterRoomInfo:(NSString *)sessionSn
            successBlock:(TMNNetworkSuccessObjectBlock)successBlock
             failedBlock:(TMNNetworkFailedBlock)failedBlock{

    TMUser *currentUser = [self currentUser];
    NSString *clientSn = currentUser.clientSn;
    NSString *token = currentUser.token;
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"clientSn":clientSn,@"sessionSn":sessionSn,@"brandId":@(TMNBrandID_TutorABC),@"token":token}];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/enter",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        if(response && (response.status.code == 100000||response.status.code == 100201)){
            
            successBlock(response);
            
        }
        else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
}

- (void)sendCustomerAttend:(NSString *)sessionSn
              successBlock:(TMNNetworkSuccessObjectBlock)successBlock
               failedBlock:(TMNNetworkFailedBlock)failedBlock {
 
    
    TMUser *currUser = [self currentUser];
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"clientSn":currUser.clientSn,
                                                              @"sessionSn":sessionSn,
                                                              @"brandId":@(TMNBrandID_TutorABC),
                                                              @"token":currUser.token}];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/customerAttend",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        if(response && (response.status.code == 100000||response.status.code == 100201)){
            
            successBlock(response);
            
        }
        else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
}

- (void)cancelLesson:(NSArray *)lessons
        successBlock:(TMNNetworkSuccessArrayBlock)successBlock
         failedBlock:(TMNNetworkFailedBlock)failedBlock{
    
    if(!lessons){
        failedBlock([NSError errorWithDomain:@"lessons is empty" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }else{
        if(lessons.count ==0){
            failedBlock([NSError errorWithDomain:@"lessons is empty" code:kInAPPErrorCode userInfo:nil], nil);
            return;
        }
    }
    
    TMUser *currentUser = [self currentUser];
    
    if(!currentUser || !currentUser.token || !currentUser.clientSn){
        failedBlock([NSError errorWithDomain:@"current user is not found" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSString *clientSn = currentUser.clientSn;
    NSString *token = currentUser.token;
    NSString *email = currentUser.account;
    NSMutableArray *data = [NSMutableArray array];
    
    for (TMLesson *lesson in lessons) {
        [data addObject:@{@"clientSn":clientSn, @"startTime":@(lesson.startTime)}];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"brandId":@(TMNBrandID_VIPABC),@"email":email,@"token":token,@"fromDevice":currentUser.deviceID,@"data":jsonString}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
   
    [manager POST: [NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/cancel",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        
        
        if(response && (response.status.code == 100000 || response.status.code == 100202)){
            
            if(response.data && response.data.count>0){
                
                NSArray *lessonResponse= [TMLessonResponse objectArrayWithKeyValuesArray:response.data];
                
                for (int i=0; i<[lessonResponse count]; i++) {
                    TMLessonResponse *lessonResp = [lessonResponse objectAtIndex:i];
                    TMLesson *lesson=[lessons objectAtIndex:i];
                    lessonResp.usePoints = lesson.usePoints;
                    lessonResp.sessionType = lesson.sessionType;
                }
                
                [[TMPlanLessonUtil sharedUtil] forceSyncLessonsWithResultBlock:^(NSError *error, NSArray *lessons) {
                    
                    
                    if(response && (response.status.code == 100000 || response.status.code == 100202)){
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLessonCanceledNotification object:nil];
                        successBlock(lessonResponse);
                        return;
                    }else{
                        
                        [self checkObject:responseObject
                             successBlock:nil
                              failedBlock:failedBlock];
                        
                        return;
                    }
                }];
            }else{
                // response data is empty
                [self checkObject:responseObject
                     successBlock:nil
                      failedBlock:failedBlock];
                return;
            }

        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
            return;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
    
}
- (void)checkInLesson:(NSString *)sessionSn
         successBlock:(TMNNetworkSuccessDicBlock)successBlock
          failedBlock:(TMNNetworkFailedBlock)failedBlock{
    
    TMUser *currentUser = [self currentUser];
    NSString *clientSn = currentUser.clientSn;
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"token":[self currentUser].token,@"clientSn":clientSn,@"brandId":@(TMNBrandID_TutorABC),@"sessionSn":sessionSn}];
    

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/checkin",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            successBlock(response.data);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
    
    
}
- (void)getClassListWithPageSize:(int) pageSize
                       pageIndex:(int) pageIndex
                       startTime:(NSString *)startTime
                         endTime:(NSString *)endTime
                          isDesc:(BOOL)isDesc
                    successBlock:(TMNNetworkSuccessDicBlock) successBlock
                     failedBlock:(TMNNetworkFailedBlock) failedBlock {
    
    
    
    TMUser *user = [self currentUser];
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"tmpl" : @"json",
                                                              @"clientSn" : @([user.clientSn intValue]),
                                                              @"brandId" : @(TMNBrandID_TutorABC),
                                                              @"pageSize" : @(pageSize),
                                                              @"pageIndex" : @(pageIndex),
                                                              @"startTime" : startTime,
                                                              @"endTime" : endTime,
                                                              @"token":[self currentUser].token}];
    
    params[@"isDesc"] = isDesc ? @"True" : @"False";

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:[NSString stringWithFormat:@"%@/mobcommon/webapi/aftersession/1/getClassList",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"resp: %@", responseObject);
        
        [self checkObject:responseObject
             successBlock:successBlock
              failedBlock:failedBlock];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err: %@", error);
        failedBlock(error, nil);
    }];    
    
}

- (void)getVideoRecordsWithPage:(int) page
                    recordCount:(int) recordCount
                      startDate:(NSString *)startDate
                        endDate:(NSString *)endDate
                   successBlock:(TMNNetworkSuccessDicBlock) successBlock
                    failedBlock:(TMNNetworkFailedBlock) failedBlock {
    
    
    TMUser *user = [self currentUser];
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"tmpl" : @"json",
                                                              @"clientSn" :user.clientSn,
                                                              @"brandId" : @(TMNBrandID_VIPABC),  // problem
                                                              @"startDate": startDate,
                                                              @"endDate": endDate,
                                                              @"page" : @(page),
                                                              @"recordCount" : @(recordCount),
                                                              @"token":user.token}];
    
    
    
    if (page == 0 || recordCount == 0) {
        [params removeObjectForKey:@"page"];
        [params removeObjectForKey:@"recordCount"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/getVideoRecords",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
         //NSLog(@"Videorecord resp: %@", responseObject);
        [self checkObject:responseObject
             successBlock:successBlock
              failedBlock:failedBlock];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err: %@", error);
        failedBlock(error, nil);
    }];
    
}

- (void)getVideoUrlWithSessionSn:(NSString *)sessionSn
                          fileSn:(NSString *)fileSn
                      materialSn:(NSString *)materialSn
                    successBlock:(TMNNetworkSuccessDicBlock)successBlock
                     failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    
    
    TMUser *user = [self currentUser];
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"clientSn": user.clientSn,
                                                              @"brandId": @(TMNBrandID_TutorABC),
                                                              @"sessionSn": sessionSn,
                                                              @"fileSn": fileSn,
                                                              @"materialSn": materialSn,
                                                              @"token": user.token}];

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/viewvideo",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Videorecord resp: %@", responseObject);
        [self checkObject:responseObject
             successBlock:successBlock
              failedBlock:failedBlock];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"err: %@", error);
        failedBlock(error, nil);
    }];

}

- (void)getConsultantInfoWithSn:(NSString *)consultantSn
                   successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                    failedBlock:(TMNNetworkFailedBlock)failedBlock{
    

    TMUser *currentUser = [self currentUser];
    
    if(!currentUser || !currentUser.token || !currentUser.clientSn){
        failedBlock([NSError errorWithDomain:@"current user is not found" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"token":currentUser.token,@"consultantSn":consultantSn}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/consultant/1/getconsultantinfobysn",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            TMConsultant *consultant = [TMConsultant objectWithKeyValues:response.data[0]];
            
            successBlock(consultant);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
    
}

- (void)getTimesuccessBlock:(TMNNetworkSuccessObjectBlock)successBlock
                failedBlock:(TMNNetworkFailedBlock) failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"token":[self currentUser].token}];
  
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/getTime",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
       
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            NSDictionary *dic = response.data;
            successBlock(dic);
            
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];


}

- (void)sendClassInfo:(NSMutableArray *) lessonlist
         successBlock:(TMNNetworkSuccessObjectBlock) successBlock
          failedBlock:(TMNNetworkFailedBlock) failedBlock{
    
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (int i=0; i<[lessonlist count]; i++) {
        TMLesson *lesson=[lessonlist objectAtIndex:i];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic setValue:[self currentUser].clientSn forKey:@"clientSn"];
        [dic setValue:[NSNumber numberWithLongLong:lesson.startTime] forKey:@"startTime"];
        [dic setValue:[NSNumber numberWithInt:lesson.sessionType] forKey:@"sessionType"];
        [array addObject:dic];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString;
    if (! jsonData) {
        // NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"jsonString=%@",jsonString);
        
    }
    NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:@"account"];
    
    
    if(!account || !jsonString){
        failedBlock([NSError errorWithDomain:@"parameter is nil" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"tmpl":@"json",@"email":account,@"fromDevice":@"testMob",@"data":jsonString,@"token":[self currentUser].token,@"brandId":[NSNumber numberWithInt:TMNBrandID_VIPABC]}];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/reserve",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
        
            NSDictionary *dic = response.data[0];
            //NSLog(@"dic=%@",dic);
            successBlock(dic);
            
        }else{
            NSDictionary *dic = response.data[0];
            //NSLog(@"err dic=%@",dic);
            failedBlock([NSError errorWithDomain:@"" code:kInAPPErrorCode userInfo:nil], dic);
        }
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];
    

}

- (void)reserveLessons:(NSArray *) lessons
          successBlock:(TMNNetworkSuccessArrayBlock) successBlock
           failedBlock:(TMNNetworkFailedBlock) failedBlock{
    
    TMUser *currentUser = [self currentUser];
    
    if(!currentUser || !currentUser.token || !currentUser.clientSn){
        failedBlock([NSError errorWithDomain:@"current user is not found" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSString *clientSn = currentUser.clientSn;
    NSString *token = currentUser.token;
    NSString *email = currentUser.account;
    
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for (int i=0; i<[lessons count]; i++) {
        TMLesson *lesson=[lessons objectAtIndex:i];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic setValue:clientSn forKey:@"clientSn"];
        [dic setValue:[NSNumber numberWithLongLong:lesson.startTime] forKey:@"startTime"];
        [dic setValue:[NSNumber numberWithInt:lesson.sessionType] forKey:@"sessionType"];
        
        if(lesson.classDetail && lesson.classDetail.lobbySn){
            [dic setValue:@(lesson.classDetail.lobbySn) forKey:@"lobbySn"];
        }
        
        [array addObject:dic];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString;
    if (! jsonData) {
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    if(!email || !jsonString || !token){
        failedBlock([NSError errorWithDomain:@"parameter is nil" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"email":email,@"fromDevice":currentUser.deviceID,@"data":jsonString,@"token":token,@"brandId":@(TMNBrandID_VIPABC)}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/reserve",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        [[TMPlanLessonUtil sharedUtil] forceSyncLessonsWithResultBlock:^(NSError *error, NSArray *pLessons) {
            TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
            if(response && (response.status.code == 100000 || response.status.code == 100202)){
                
                NSArray *array = [TMLessonResponse objectArrayWithKeyValuesArray:response.data];
                
                for (int i=0; i<[array count]; i++) {
                    TMLessonResponse *lessonResp = [array objectAtIndex:i];
                    if(lessons && lessons.count == [array count]){
                        TMLesson *lesson=[lessons objectAtIndex:i];
                        lessonResp.usePoints = lesson.usePoints;
                    }
                }
                
                successBlock(array);
            }else{
                [self checkObject:responseObject
                     successBlock:nil
                      failedBlock:failedBlock];
            }
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failedBlock(error, nil);
    }];
    
    
}

- (void)checkNewbieWithSuccessBlock:(TMNNetworkSuccessObjectBlock) successBlock
                        failedBlock:(TMNNetworkFailedBlock) failedBlock{
    
    TMUser *currentUser = [self currentUser];
    
    if(!currentUser || !currentUser.token || !currentUser.clientSn){
        failedBlock([NSError errorWithDomain:@"current user is not found" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSString *clientSn = currentUser.clientSn;
    NSString *token = currentUser.token;
    NSString *deviceType = @"1";
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"clientSn":clientSn,@"deviceType":deviceType,@"token":token,@"brandId":@(TMNBrandID_TutorABC)}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/isNewbie",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        if(response && (response.status.code == 100000)){
            
            successBlock([TMNewbieResponse objectWithKeyValues:response.data]);
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failedBlock(error, nil);
    }];
    
    
}

- (void)sendRatingInfoWithSn:(NSString *) sessionSn
                      rating:(NSMutableDictionary *) rating
                  suggestion:(NSString *) suggestion
                  compliment:(NSString *) compliment
             isContactClient:(BOOL) isContactClient
                successBlock:(TMNNetworkSuccessObjectBlock)                     successBlock
                 failedBlock:(TMNNetworkFailedBlock) failedBlock{


    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:rating
                                                       options:NSJSONWritingPrettyPrinted 
                                                         error:nil];
    NSString *jsonString;
    if (! jsonData) {
        // NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"jsonString=%@",jsonString);
        
    }
   
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"tmpl":@"json",@"clientSn":[self currentUser].clientSn,@"sessionSn":sessionSn,@"rating":jsonString,@"suggestion":suggestion,@"compliment":compliment,@"isContactClient":isContactClient?@"true":@"false",@"token":[self currentUser].token,@"brandId":@(TMNBrandID_VIPABC)}];
    //NSLog(@"params=%@",params);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/aftersession/1/setRating",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            NSDictionary *dic = response.data;
            successBlock(dic);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];

    
}

- (void)getMaterialInfoWithSn:(NSString *)materialSn
                 successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                  failedBlock:(TMNNetworkFailedBlock)failedBlock{

    
    TMUser *currentUser = [self currentUser];
    
    if(!currentUser || !currentUser.token || !currentUser.clientSn){
        failedBlock([NSError errorWithDomain:@"current user is not found" code:kInAPPErrorCode userInfo:nil], nil);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"token":currentUser.token,@"materialSn":materialSn}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/material/1/getmaterialinfobysn",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMArrayResponse *response = [TMArrayResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            TMMaterial *material = [TMMaterial objectWithKeyValues:response.data[0]];
            
            successBlock(material);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];

}
- (void)getMaterialFileWithPath:(NSString *)filePath
                   successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                    failedBlock:(TMNNetworkFailedBlock)failedBlock{


    NSMutableDictionary *params = [NSMutableDictionary
                               dictionaryWithDictionary:@{@"token":[self currentUser].token,@"filePath":filePath,@"brandId":[NSNumber numberWithInt:1]}];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/material/1/getMaterials",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
    
    TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
    if(response && response.status.code == 100000){
        
        NSDictionary *dic = response.data;
        successBlock(dic);
        
    }else{
        [self checkObject:responseObject
             successBlock:nil
              failedBlock:failedBlock];

    }
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
        failedBlock(error, nil);
    }];

}

- (void)getVideoInfoWithfileSn:(int)fileSn
                    materialSn:(int)materialSn
                     sessionSn:(NSString *)sessionSn
                  successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                   failedBlock:(TMNNetworkFailedBlock)failedBlock{

   
    
    NSMutableDictionary *params = [NSMutableDictionary
                                   dictionaryWithDictionary:@{@"clientSn":[self currentUser].clientSn,@"sessionSn":sessionSn,@"token":[self currentUser].token,@"fileSn":[NSNumber numberWithInt: fileSn],@"materialSn":[NSNumber numberWithInt: materialSn],@"brandId":[NSNumber numberWithInt: 1]}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/session/1/viewvideo",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        
        if(response && response.status.code == 100000){
    
            NSDictionary *dic = response.data;
            successBlock(dic);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];

}
- (void)getReviewRatingInfoWithSn:(NSString *) sessionSn
                     successBlock:(TMNNetworkSuccessObjectBlock)                     successBlock
                      failedBlock:(TMNNetworkFailedBlock) failedBlock{
    
    //NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"tmpl":@"json",@"clientSn":@"1089709",@"sessionSn":@"2015081909839",@"brandId":[NSNumber numberWithInt: 1],@"token":[self currentUser].token}];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"tmpl":@"json",@"clientSn":[self currentUser].clientSn,@"sessionSn":sessionSn,@"brandId":[NSNumber numberWithInt: 1],@"token":[self currentUser].token}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/aftersession/1/getClassRating",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        
        if(response && response.status.code == 100000){
            
            NSDictionary *dic = response.data;
            //NSLog(@"dic=%@",dic);
            successBlock(dic);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];




}
- (void)setFavoriteConsultantWithSn:(NSString *) consultantSn
                             action:(int) action
                       successBlock:(TMNNetworkSuccessDicBlock)successBlock
                        failedBlock:(TMNNetworkFailedBlock) failedBlock{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"tmpl":@"json",@"clientSn":[self currentUser].clientSn,@"consultantSn":consultantSn,@"action":[NSNumber numberWithInt:action],@"token":[self currentUser].token,@"brandId":[NSNumber numberWithInt:1]}];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
//    NSString *params=[NSString stringWithFormat:@"%@/mobcommon/webapi/consultant/1/setFavoriteConsultant?clientSn=%@&consultantSn=%@&action=%d&token=%@&brandId=%d",self.urlHost,[self currentUser].clientSn,consultantSn,action,[self currentUser].token,1];
    [manager POST:[NSString stringWithFormat:@"%@/mobcommon/webapi/consultant/1/setFavoriteConsultant",self.urlHost] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
  //  [manager GET:params parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        TMDictResponse *response = [TMDictResponse objectWithKeyValues:responseObject];
        if(response && response.status.code == 100000){
            
            if(action){
                [[TMClassUtil sharedUtil].favoriteConsultants setValue:@YES forKey:consultantSn];
            }else{
                [[TMClassUtil sharedUtil].favoriteConsultants setValue:@NO forKey:consultantSn];
            }
            
            successBlock(response.data);
            
        }else{
            [self checkObject:responseObject
                 successBlock:nil
                  failedBlock:failedBlock];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failedBlock(error, nil);
    }];

}

#pragma mark - push notification

- (void)registerPushNotificaionWithToken:(NSString *)appToken
                                 isValid:(BOOL)isValid
                            successBlock:(TMNNetworkSuccessDicBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock {
    // 裝置唯一識別碼
    NSString *deviceId = [self currentUser].deviceID;
    // muchnewdb.dbo.Client_basic.sn / AES Decode
    NSString *clientSn = [self currentUser].clientSn;
    
    if (deviceId && appToken && clientSn) {
        int isValidNum = 1;
        if (!isValid) {
            isValidNum = 0;
        }
        
        NSDictionary *params = @{@"DeviceId":deviceId, @"AppToken":appToken, @"AppKey":kPushAppKey, @"Platform":kPushPlatform, @"DeviceOS":kPushDeviceOS, @"ClientSn":clientSn, @"Valid": @(isValidNum), @"BrandId": @(TMNBrandID_VIPABC)};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSString *url = [NSString stringWithFormat:@"%@registclientapptoken", kPnApiURL];
        [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
            if (successBlock) {
                successBlock(responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failedBlock) {
                failedBlock(error, nil);
            }
        }];
    }
    
}

- (void)registerAllChannelPushNotificaionWithToken:(NSString *)appToken
                                           isValid:(BOOL)isValid
                            successBlock:(TMNNetworkSuccessDicBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    int isValidNum = 1;
    if (!isValid) {
        isValidNum = 0;
    }
    
    // 所有後台推播channel key值
    NSString *allChannelKeys = [[TMNConstantObj sharedInstance] allReminderKeys];
    
    //NSLog(@"---allChannelKeys=%@", allChannelKeys);
    
    NSDictionary *params = @{@"AppToken":appToken, @"Channels":allChannelKeys, @"Valid":@(isValidNum), @"BrandId": @(TMNBrandID_TutorABC)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *url = [NSString stringWithFormat:@"%@addorupdateclientchannel", kPnApiURL];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failedBlock) {
            failedBlock(error, nil);
        }
    }];
    
}

- (void)updatePushNotificaionWithToken:(NSString *)appToken
                               reminderType:(TMNReminderType)reminderType
                                enable:(BOOL)isEnable
                            successBlock:(TMNNetworkSuccessDicBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock {
    
    NSString *isEnableStr = @"1";
    if (!isEnable) {
        isEnableStr = @"0";
    }
    
    NSString *channelKey = [[TMNConstantObj sharedInstance] channelKeyForReminderType:reminderType];
    //NSLog(@"---update channelKey=%@, appToken=%@", channelKey, appToken);
    
    NSDictionary *params = @{@"AppToken":appToken, @"Channels":channelKey, @"Valid":isEnableStr, @"BrandId": @(TMNBrandID_TutorABC)};
    
    NSString *url = [NSString stringWithFormat:@"%@addorupdateclientchannel", kPnApiURL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failedBlock) {
            failedBlock(error, nil);
        }
    }];
}

- (void)updateBadgeWithToken:(NSString *)appToken {
    if (nil == appToken) {
        return;
    }
    NSDictionary *params = @{@"AppToken":appToken, @"BadgeNumber":@(0)};
    
    NSString *url = [NSString stringWithFormat:@"%@updatebadge", kPnApiURL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}

+ (BOOL)isNetworkReachable {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

@end
@implementation TMUser

- (NSArray *)availableReservableSessionType{
    if(!_availableSessionType) return @[];
    
    NSPredicate *bPredicate =
    [NSPredicate predicateWithFormat:@"SELF != 91"];
    NSArray *array = [_availableSessionType filteredArrayUsingPredicate:bPredicate];
    
    return array;
}

@end

@implementation TMLessonResponse


@end


@implementation TMConfig

@end

@implementation TMLang

@end

@implementation TMNewbieResponse


@end

