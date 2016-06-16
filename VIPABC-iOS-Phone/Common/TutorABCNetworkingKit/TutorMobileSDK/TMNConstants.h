//
//  TMNConstants.h
//  TutorMobileNative
//
//  Created by Oxy Hsing_邢傑 on 8/31/15.
//  Copyright (c) 2015 TutorABC, Inc. All rights reserved.
//

#ifndef TutorMobileNative_TMNConstants_h
#define TutorMobileNative_TMNConstants_h

typedef void(^TMNNetworkSuccessObjectBlock) (id object);
typedef void(^TMNNetworkSuccessDicBlock) (NSDictionary * responseDic);
typedef void(^TMNNetworkSuccessArrayBlock) (NSArray * responseArray);

static const NSString *kIsInReview = @"TMNIsInReview";

#define isLobby(arg) (arg == TMNClassSessionType_Lobby10 || arg == TMNClassSessionType_Lobby20 || arg == TMNClassSessionType_Lobby45)

/**
 *  Should be clear that, if API response as particial Fail, ex: 部分定課失敗
 *  still consider this case as Failed.
 *
 *  @param error
 *  @param responseObject
 */
typedef void(^TMNNetworkFailedBlock) (NSError * error, id responseObject);

typedef NS_ENUM(NSInteger, TMNClassSessionType) {
    TMNClassSessionType_Undefined = 0,

    TMNClassSessionType_1on1 = 1,

    TMNClassSessionType_1on2 = 2,

    TMNClassSessionType_1on3 = 3,

    TMNClassSessionType_1on4 = 4,
    
    TMNClassSessionType_1on6 = 6,

    TMNClassSessionType_Lobby10 = 10,

    TMNClassSessionType_Lobby20 = 20,
    
    TMNClassSessionType_Lobby45 = 99,
    
    TMNClassSessionType_PowerSession = 91

};

typedef NS_ENUM(NSUInteger, TMNBrandID) {
    TMNBrandID_TutorABC = 1,
    /**
     *  小班制 1on1
     */
    TMNBrandID_VIPABC = 2,
    /**
     *  年約小班 (2,6,3,14,4)
     */
    TMNBrandID_TJR = 3,
    /**
     *  超值小班 (21)
     */
    TMNBrandID_VJR = 4
};


typedef NS_ENUM(NSUInteger, TMPeriod) {
    TMPeriod_All = 0,
    TMPeriod_Morning = 1,
    TMPeriod_Afternoon = 2,
    TMPeriod_Night = 3
};


typedef NS_ENUM(NSUInteger, TMNUserType) {
    // 付費會員
    TMNUserType_ContractMember = 1,
    // 非在期會員
    TMNUserType_NonContractMember = 2,
    // 未登入
    TMNUserType_NotLogin = 3
};

typedef NS_ENUM(NSInteger, TMNTestDeviceResult) {
    TMNTestDeviceResult_UnTest = 0,
    TMNTestDeviceResult_Fail = -1,
    TMNTestDeviceResult_Success = 1
};

// 推播提醒的類別
typedef enum : NSUInteger {
    ReminderNone, // 用來代表非推播項目
    Reminder5hr, // 上課前5小時提醒
    Reminder1hr, // 上課前1小時提醒
    Reminder15min, // 上課前15分鐘提醒
    Reminder65min // 上課前65分鐘報到提醒(由於是讓客戶認知訂課之後，開課前20-65分鐘報到才會保留，所以於65分鐘先提醒報到。接著才會於課前60分收到推播提醒上課)
} TMNReminderType;

// 呼叫api成功回覆的code
static const int kResponseCodeSuccess = 100000;

// TODO: 改為後台登陸的app id
// notification preprocessor
#ifdef PN_STAGE
static const NSString * kPnApiURL = @"http://192.168.23.109:8016/pushmsg_open/webapi/client/1/";
// ---- push notification on stage ----
// 與推播平台註冊的Key
static const NSString * kPushAppKey = @"B2BCE9FD-1A77-43FC-BFAE-2B9C30785972-1";
#define kPushChannelKey @{\
@(Reminder5hr): @"C-3c109aa5568da13492977ff261ed8a07", \
@(Reminder1hr): @"C-1fe70ed42b7a6d537d6297f18f5c115e", \
@(Reminder15min): @"C-599daee1a06a7ae8a88378d581c55436", \
@(Reminder65min): @"C-c77b36e6f980a8e90c009fe73961a7b4" \
};

#elif PN_STAGE_ENTERPRISE
static const NSString * kPnApiURL = @"http://192.168.23.109:8016/pushmsg_open/webapi/client/1/";
// 與推播平台註冊的Key
static const NSString * kPushAppKey = @"120642E2-C4E3-4A10-8ED8-7824D506F885-1";
#define kPushChannelKey @{\
@(Reminder5hr): @"C-072b8ba420aa4ac5b4f1ee5dc0e99c61", \
@(Reminder1hr): @"C-aea4cd8d441e4ac535f393ddacff0250", \
@(Reminder15min): @"C-a666f41dc3124c75c504bd5f0301e74e",\
@(Reminder65min): @"C-724f37aa105b876fd5cd7668242d72f5" \
}

#else
static const NSString * kPnApiURL = @"http://mobapi.tutorabc.com/pushmsg/webapi/client/1/";
// ---- push notification enterprise on production ----
// 與推播平台註冊的Key
static const NSString * kPushAppKey = @"3B73D87F-D3DC-40FC-BB2B-39737471D550-1";
#define kPushChannelKey @{\
@(Reminder5hr): @"C-43f70a4f68e8416f2f532f39d64b56bf",\
@(Reminder1hr): @"C-a0f02a7cac44481114f323a0c6c5750d", \
@(Reminder15min): @"C-c92525533397f6899ff24936ac372135", \
@(Reminder65min): @"C-c0e8790ff0d21bcc52d49a9d6d017050" \
};
// ---- push notification enterprise on production end----
#endif
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define IsPad [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad
#define HEIGHTSCALESIZE SCREEN_HEIGHT/768
// 推播商名稱(Getui/GCM/APNs)
static const NSString *kPushPlatform = @"APNs";
// 作業系統名稱(iOS/Android)
static const NSString *kPushDeviceOS = @"iOS";
// 是否已將推播設定儲存到推播server
static const NSString *kIsSave2PushServer = @"TWNIsSave2PushServer";
// 設定頁按下關於TutorABC要導到的網址
static const NSString *kURL4AboutTutorABC = @"http://www.tutorabc.com/aspx/Mvc/Home/YaoHtml/AboutTutorABC.html";
// 註冊帳號的網址
static const NSString *kURL4RegisterAccount = @"http://www.tutorabc.com/aspx/Mvc/User/Register";
#endif
