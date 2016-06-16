//
//  TMNNetworkLogicController.h
//  TutorMobileNative
//
//  Created by Oxy Hsing_邢傑 on 8/31/15.
//  Copyright (c) 2015 TutorABC, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNConstants.h"

#define kInAPPErrorCode 100

@class TMUser;

@interface TMNNetworkLogicController : NSObject


/**
 * Reference to Class related APIs
 http://jira.tutorabc.com:8090/display/TAR/The+list+of+API+in+SDK
 */



/**
 *  Creates and returns an `TMNNetworkLogicController` object everytime.
 *  init url host by default: http://192.168.23.109:8018
 */
+ (instancetype)sharedInstance;
- (instancetype)initWithUrlHost:(NSString *)host;

// set data after login
- (TMUser *)currentUser;

/**
 *  初始化完成後可取得 deviceId
 *
 *  @return <#return value description#>
 */
- (NSString *)getDeviceId;

/**
 * http://192.168.23.109:8018/mobcommon/webapi/track/1/start
 * 初始化時檢查版本控制
 brandId
 1: TutorABC
 2: VIPABC
 3: TJR
 4: VJR
 *  @param version          NSString, version of app
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getTrackStarterWithBrandId:(TMNBrandID)brandId
                            version:(NSString *)version
                       successBlock:(TMNNetworkSuccessDicBlock)successBlock
                        failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/config/1/getConfig
 *  Config
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getConfigWithSuccessBlock:(TMNNetworkSuccessObjectBlock)successBlock
                       failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/user/1/login?
 *  同 ReserveAPI
 *  @param successBlock
 *  @param failedBlock
 */
- (void)loginWithAccount:(NSString *) account
                password:(NSString *) password
                 brandId:(TMNBrandID) brandId
            successBlock:(TMNNetworkSuccessObjectBlock) successBlock
             failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 * http://192.168.23.109:8018/smarttv/webapi/vocabulary/1/preview?
 *  @param materialSn
 *  @param clientSn         會員編號(小孩須為加密且編碼)
 *  @param scope            default->7 : 全部資訊
 *  @param wordCount        data count
 *  @param brandId          Enum, 品牌id(品牌如TutorABC, VIPABC, TJR, VJR)
 品牌
 1 : TutorABC
 2 : VIPABC
 3 : TutorABCJr
 4 : vipabcJr
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getVocWithMaterialSn:(NSString * ) materialSn
                     clientSn:(NSString *) clientSn
                    language:(NSString *) language
                     wordCount:(int) wordCount
                     scope:(int) scope
                      brandId:(TMNBrandID) brandId
                successBlock:(TMNNetworkSuccessArrayBlock) successBlock
                 failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 * http://192.168.200.22/mobcommon/webapi/session/1/getsessioninfobysessionsn?
 sessionSn  
 clientSn
 brandId
 1: TutorABC
 2: VIPABC
 3: TJR
 4: VJR
 token	auth
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getClassInfoWithSn:(NSString *) sessionSn
                 successBlock:(TMNNetworkSuccessObjectBlock) successBlock
                  failedBlock:(TMNNetworkFailedBlock) failedBlock;

/**
 *  http://192.168.23.109:8018/mobcommon/webapi/freesession/1/getFreeVideoCategory?
 *  取得免費課程類別清單
 *
 *  @param brandId          Enum, 品牌id(品牌如TutorABC, VIPABC, TJR, VJR)
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getFreeSessionCategoryWithBrandId:(TMNBrandID)brandId
                             successBlock:(TMNNetworkSuccessDicBlock)successBlock
                              failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/freesession/1/getFreeVideoList?
 *  按類別取得免費課程清單
 *
 *  @param brandId          Enum, 品牌id(品牌如TutorABC, VIPABC, TJR, VJR)
 *  @param categoryIndex    int, 前端所選類別index(如藝術娛樂, 生活趣聞...)
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getFreeSessionListWithBrandId:(TMNBrandID)brandId
                            categoryIndex:(int)categoryIndex
                             successBlock:(TMNNetworkSuccessDicBlock)successBlock
                              failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/freesession/1/getDetail?
 *  取得免費課程錄影檔資訊
 *
 *  @param brandId      Enum, 品牌id(品牌如TutorABC, VIPABC, TJR, VJR)
 *  @param fileName     NSString, file name from getFreeSessionListWithBrandId:categoryIndex:successBlock:failedBlock:
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getFreeSessionRecordInfoWithBrandId:(TMNBrandID)brandId
                                       fileName:(NSString *)fileName
                                   successBlock:(TMNNetworkSuccessDicBlock)successBlock
                                    failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/vocabulary/1/preview?
 *  取得單字清單
 *
 *  @param brandId      Enum, 品牌id(品牌如TutorABC, VIPABC, TJR, VJR)
 *  @param materialSn   NSString, materialSn from getClassInfoWithSn:successBlock:failedBlock:
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getVocabularyListWithBrandId:(TMNBrandID)brandId
                              materialSn:(NSString *)materialSn
                            successBlock:(TMNNetworkSuccessDicBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/envTest/1/testErrReason?
 *  裝置測試未完成與測試失敗時送出記錄到server
 *
 *  @param resultStatus TMNTestDeviceResult_UnTest = 0, TMNTestDeviceResult_Fail = -1, TMNTestDeviceResult_Success = 1
 *  @param osVersion    [[UIDevice currentDevice] systemVersion]
 *  @param successBlock
 *  @param failedBlock
 */
- (void)sendDeviceTestErrReasonForStatus:(TMNTestDeviceResult)resultStatus
                               osVersion:(NSString *)osVersion
                            successBlock:(TMNNetworkSuccessDicBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/envTest/1/testPass?
 *  裝置測試成功時送出記錄到server
 *
 *  @param headsetVol   int, volumn of headset
 *  @param micVol       int, volumn of microphone
 *  @param osVersion    [[UIDevice currentDevice] systemVersion]
 *  @param successBlock
 *  @param failedBlock
 */
- (void)sendDeviceTestSuccessWithHeadsetVol:(int)headsetVol
                                     micVol:(int)micVol
                                  osVersion:(NSString *)osVersion
                               successBlock:(TMNNetworkSuccessDicBlock)successBlock
                                failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/getTimeTbl?
 *  Get Time Table
 *
 *  @param clientSn         NSString, 會員編號(小孩須為加密且編碼)
 *  @param brandId          Enum, 品牌id(品牌如TutorABC, VIPABC, TJR, VJR)
 *  @param beginTime        (long long), timestamp in milliseconds
 *  @param endTime          (long long), timestamp in milliseconds
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getTimeTblWithClientSn:(NSString *)clientSn
                       brandId:(TMNBrandID)brandId
                   sessionType:(TMNClassSessionType)sessionType
                     beginTime:(long long)beginTime
                       endTime:(long long)endTime
                  successBlock:(TMNNetworkSuccessArrayBlock)successBlock
                   failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/getnextsession?
 *  Get NextSession
 *  @param beginTime        (long long), timestamp in milliseconds
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getNextSession:(long long)beginTime
           successBlock:(TMNNetworkSuccessObjectBlock)successBlock
            failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/getplan?
 *  Get Plan
 *
 *  @param beginTime        (long long), timestamp in milliseconds
 *  @param endTime          (long long), timestamp in milliseconds
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getPlanWithBeginTime:(long long)beginTime
                      endTime:(long long)endTime
                 successBlock:(TMNNetworkSuccessArrayBlock)successBlock
                  failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/contract/1/getcontractinfo?
 *  取得合約資訊
 *
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getContractInfoWithSuccessBlock:(TMNNetworkSuccessArrayBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/enter?
 *  進入教室
 *
 *  @param sessionSn        NSString,   session serial number
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getEnterRoomInfo:(NSString *)sessionSn
            successBlock:(TMNNetworkSuccessObjectBlock)successBlock
             failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/customerAttend?
 *  send attend status to IMS
 *
 *  @param sessionSn    sessionSn is useless for demo session, but send always for convenient
 *  @param successBlock Only shown on console
 *  @param failedBlock  log to crashlytics
 */
- (void)sendCustomerAttend:(NSString *)sessionSn
              successBlock:(TMNNetworkSuccessObjectBlock)successBlock
               failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/cancel?
 *  Cancel session
 *
 *  @param lessons          NSArray, compose by TMLesson
 *  @param successBlock
 *  @param failedBlock
 */
- (void)cancelLesson:(NSArray *)lessons
         successBlock:(TMNNetworkSuccessArrayBlock)successBlock
          failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/checkin?
 *  超值小班制報到
 *
 *  @param sessionSn        NSString,   session serial number
 *  @param successBlock
 *  @param failedBlock
 */
- (void)checkInLesson:(NSString *)sessionSn
         successBlock:(TMNNetworkSuccessDicBlock)successBlock
          failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/getclientAttendListDate
 *  @param page          int     index of page
 *  @param recordCount   int     number of data for determinated page
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getLearningHistoryYearAndMonthWithPage:(int)page
                                   recordCount:(int)recordCount
                                  successBlock:(TMNNetworkSuccessDicBlock)successBlock
                                   failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/aftersession/1/getClassList
 *
 *  @param pageSize         default as 100
 *  @param pageIndex        default as 1
 *  @param startTime        timestamp string
 *  @param endTime          timestamp string
 *  @param isDesc           default as YES
 *  @param successBlock     invoke when request success
 *  @param failedBlock      invoke when request fail
 */
- (void)getClassListWithPageSize:(int) pageSize
                        pageIndex:(int) pageIndex
                        startTime:(NSString *)startTime
                          endTime:(NSString *)endTime
                           isDesc:(BOOL)isDesc
                     successBlock:(TMNNetworkSuccessDicBlock) successBlock
                      failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/getVideoRecords
 * @param page          int     index of page
 * @param recordCount   int     number of data for determinated page
 * @param startDate     string  the start of month date
 * @param endDate       string  the end of month date
 * @param successBlock  invoke when request success
 * @param failedBlock   invoke when request fail
 */
- (void)getVideoRecordsWithPage:(int) page
             recordCount:(int) recordCount
               startDate:(NSString *)startDate
                 endDate:(NSString *)endDate
            successBlock:(TMNNetworkSuccessDicBlock) successBlock
             failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/viewvideo
 * @param page          int     index of page
 * @param recordCount   int     number of data for determinated page
 * @param startDate     string  the start of month date
 * @param endDate       string  the end of month date
 * @param successBlock  invoke when request success
 * @param failedBlock   invoke when request fail
 */
- (void)getVideoUrlWithSessionSn:(NSString *) sessionSn
                           fileSn:(NSString *) fileSn
                       materialSn:(NSString *)materialSn
                     successBlock:(TMNNetworkSuccessDicBlock) successBlock
                      failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/consultant/1/getconsultantinfobysn
 *
 *  @param consultantSn serial number of consultant
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getConsultantInfoWithSn:(NSString *)consultantSn
                    successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                     failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 * http://192.168.23.109:8022/mobcommon/webapi/material/1/getmaterialinfobysn?
 materialSn
 token	auth
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getMaterialInfoWithSn:(NSString *)materialSn
                    successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                     failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 * http://192.168.23.109:8018/mobcommon/webapi/material/1/getMaterials
 filePath
 token	auth
 brandId
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getMaterialFileWithPath:(NSString *)filePath
                  successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                   failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/viewvideo?
 *
 *  @param fileSn       int, serial number of file
 *  @param materialSn   int, serial number of material
 *  @param sessionSn    NSString, serial number of session
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getVideoInfoWithfileSn:(int)fileSn
                     materialSn:(int)materialSn
                      sessionSn:(NSString *)sessionSn
                   successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                    failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  http://api.vipabc.com/reservationapi/ClassRating/GetClassRating?
 *
 *  @param sessionSn    NSString, serial number of session
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getReviewRatingInfoWithSn:(NSString *) sessionSn
                            successBlock:(TMNNetworkSuccessObjectBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *  http://api.vipabc.com/mobcommon/webapi/session/1/getTime
 *
 *  @param successBlock
 *  @param failedBlock
 */
- (void)getTimesuccessBlock:(TMNNetworkSuccessObjectBlock)successBlock
                       failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/reserve
 *
 *  @param lessonlist   NSMutableArray, compose by TMLesson
 *  @param successBlock
 *  @param failedBlock
 */
- (void)sendClassInfo:(NSMutableArray *) lessonlist
                              successBlock:(TMNNetworkSuccessObjectBlock) successBlock
                               failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *http://192.168.23.109:8018/mobcommon/webapi/session/1/reserve?
 *
 *  @param lessonlist   NSArray, compose by TMLesson
 *  @param successBlock
 *  @param failedBlock
 */

- (void)reserveLessons:(NSArray *) lessons
           successBlock:(TMNNetworkSuccessArrayBlock) successBlock
            failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *  http://192.168.23.109:8018/mobcommon/webapi/session/1/isNewbie
 *
 *  @param successBlock
 *  @param failedBlock
 */
- (void)checkNewbieWithSuccessBlock:(TMNNetworkSuccessObjectBlock) successBlock
                         failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 * http://192.168.23.109:8018/mobcommon/webapi/aftersession/1/setRating?
 clientSn
 sessionSn
 brandId
 rating
 suggestion
 compliment
 isContactClient
 token	auth
 *  @param successBlock
 *  @param failedBlock
 */
- (void)sendRatingInfoWithSn:(NSString *) sessionSn
                       rating:(NSMutableDictionary *) rating
                   suggestion:(NSString *) suggestion
                   compliment:(NSString *) compliment
              isContactClient:(BOOL) isContactClient
                 successBlock:(TMNNetworkSuccessObjectBlock) successBlock
                  failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *http://192.168.23.109:8018/mobcommon/webapi/consultant/1/setFavoriteConsultant?
 clientSn
 consultantSn
 action
 0:取消收藏
 1:加入收藏
 brandId
 token	auth
 *  @param successBlock
 *  @param failedBlock
 */
- (void)setFavoriteConsultantWithSn:(NSString *) consultantSnn
                                   action:(int) action
                              successBlock:(TMNNetworkSuccessDicBlock)                     successBlock
                               failedBlock:(TMNNetworkFailedBlock) failedBlock;


/**
 *  註冊推播token到server
 *
 *  @param appToken     與推播商註冊的Token
 *  @param isValid      是否啟用(登出要設定關閉)
 *  @param successBlock <#successBlock description#>
 *  @param failedBlock  <#failedBlock description#>
 */
- (void)registerPushNotificaionWithToken:(NSString *)appToken
                                 isValid:(BOOL)isValid
                            successBlock:(TMNNetworkSuccessDicBlock)successBlock
                             failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  註冊token的所有推播channel到server
 *
 *  @param appToken     與推播商註冊的Token
 *  @param isValid      是否啟用(登出要設定關閉)
 *  @param successBlock <#successBlock description#>
 *  @param failedBlock  <#failedBlock description#>
 */
- (void)registerAllChannelPushNotificaionWithToken:(NSString *)appToken
                                           isValid:(BOOL)isValid
                                      successBlock:(TMNNetworkSuccessDicBlock)successBlock
                                       failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  開關推播channel
 *
 *  @param appToken     與推播商註冊的Token
 *  @param reminderType App中的某一項推播管道類別
 *  @param isEnable     開 / 關
 *  @param successBlock <#successBlock description#>
 *  @param failedBlock  <#failedBlock description#>
 */
- (void)updatePushNotificaionWithToken:(NSString *)appToken
                          reminderType:(TMNReminderType)reminderType
                                enable:(BOOL)isEnable
                          successBlock:(TMNNetworkSuccessDicBlock)successBlock
                           failedBlock:(TMNNetworkFailedBlock)failedBlock;


/**
 *  reset badge to 1
 *  after every local badge reset to 0,
 *  we also need to tell server,
 *  and next time server send notification, 
 *  the correct value =1 will be send
 *
 *  @param appToken NSString :the token we got from apple
 */
- (void)updateBadgeWithToken:(NSString *)appToken;


/**
 *  網路是否有通
 *
 *  @return <#return value description#>
 */
+ (BOOL)isNetworkReachable;


@end


@interface TMUser : NSObject

@property (nonatomic, assign) BOOL isDemo;

@property (nonatomic, assign) BOOL metting;

@property (nonatomic, assign) BOOL oneVFour45;

@property (nonatomic, copy) NSString *webSite;

@property (nonatomic, copy) NSString *contractId;

@property (nonatomic, assign) BOOL approve;

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, assign) BOOL specialOneVOne45;

@property (nonatomic, strong) NSArray *availableSessionType;

@property (nonatomic, strong) NSArray *availableReservableSessionType;

@property (nonatomic, copy) NSString *token;

@property (nonatomic, assign) BOOL isUnlimitProductClient;

@property (nonatomic, assign) BOOL powerSession;

@property (nonatomic, copy) NSString *clientSn;

@property (nonatomic, copy) NSString *account;

@property (nonatomic, assign) BOOL reserveIn24Hours;

@property (nonatomic, assign) BOOL isComboProduct;

@property (nonatomic, copy) NSString *password;

// 是否為在期合約客戶(只要有任一合約在期，則為YES)
@property (nonatomic, assign) BOOL isInService;

@property (nonatomic, copy) NSString *deviceID;

@property (nonatomic, copy) NSString *username;

@property (nonatomic, copy) NSString *usernameEn;

@end

@interface TMLessonResponse : NSObject

@property (nonatomic, assign) BOOL isSuccess;

@property (nonatomic, assign) TMNClassSessionType sessionType;

@property (nonatomic, copy) NSString *successCount;

@property (nonatomic, copy) NSString *errorDesc;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *customMsg;

@property (nonatomic, assign) long long startTime;

@property (nonatomic, copy) NSString *errorCode;

@property (nonatomic, copy) NSString *usePoints;

@end

@interface TMLang : NSObject

@property (nonatomic, strong) NSDictionary *zhTW;
@property (nonatomic, strong) NSDictionary *en;

@end

@interface TMConfig : NSObject
@property (nonatomic, strong) TMLang *lang;
@property (nonatomic, assign) NSInteger maxReservation;

@end

@interface TMNewbieResponse : NSObject

@property (nonatomic, copy) NSString *context;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isNewbie;
@property (nonatomic, assign) NSTimeInterval updatedTime;

@end



