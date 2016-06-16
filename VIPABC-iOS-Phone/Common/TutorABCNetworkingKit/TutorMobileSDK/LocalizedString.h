//
//  LocalizedString.h
//  TutorMobile
//
//  Created by Eddy Tsai_蔡佳翰 on 2015/9/18.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#ifndef TutorMobile_LocalizedString_h
#define TutorMobile_LocalizedString_h

// login
#define STR_PLEASE_INPUT_SIGN_UP_EMAIL NSLocalizedString(@"請輸入您註冊時的E-mail帳號",nil)
#define STR_YOUR_PASSWORD NSLocalizedString(@"您的密碼",nil)
#define STR_LOGIN NSLocalizedString(@"登入",nil)
#define STR_FORGET_PASSWORD NSLocalizedString(@"忘記密碼？",nil)
#define STR_SIGN_UP_NOW NSLocalizedString(@"還沒有帳戶？立即註冊",nil)
#define STR_WATCH_FREE_LESSONS NSLocalizedString(@"觀看免費課程",nil)
//#define STR_PLEASE_INPUT_ACCOUNT NSLocalizedString(@"請輸入帳號",nil)
//#define STR_ACCOUNT_SHOULD_BE_EMAIL NSLocalizedString(@"帳號需為email",nil)
//#define STR_PLEASE_INPUT_PASSWORD NSLocalizedString(@"請輸入密碼",nil)
#define STR_WRONG_ACCOUNT_OR_PASSWORD_PLEASE_RETRY NSLocalizedString(@"請輸入您註冊時的E-mail帳號及密碼",nil)
#define STR_SIGN_UP_ON_TUTORABC NSLocalizedString(@"請先至TutorABC官網註冊",nil)

#define STR_TOKEN_EXPIRED NSLocalizedString(@"請重新登入",nil)
#define STR_LOGIN_FAIL NSLocalizedString(@"登入失敗，請重新登入",nil)
#define STR_LOGIN_FAIL_CAN_NOT_GET_USER_ACCOUNT NSLocalizedString(@"登入失敗，請與客服聯繫02-33659999", nil)
// font
#define FONT_AVENIR_BOOK(pSize) [UIFont fontWithName:@"Avenir-Book" size:pSize]
#define FONT_MONTSERRAT_LIGHT(pSize) [UIFont fontWithName:@"Montserrat-Light" size:pSize]
#define FONT_MONTSERRAT_REGULAR(pSize) [UIFont fontWithName:@"Montserrat-Regular" size:pSize]
#define FONT_MONTSERRAT_HAIRLINE(pSize) [UIFont fontWithName:@"Montserrat-Hairline" size:pSize]
#define FONT_ST_HEITI_TC_LIGHT(pSize) [UIFont systemFontOfSize:pSize]

// version checking
#define STR_SUGGEST_TO_UPDATE NSLocalizedString(@"為了提升服務品質，請您更新App後再登入。謝謝",nil)
#define STR_FORCE_UPDATE NSLocalizedString(@"您的版本已經過期,請立即更新",nil)
#define STR_BTN_UPDATE_NOW NSLocalizedString(@"立即更新",nil)
#define STR_BTN_MAYBE_NEXT_TIME NSLocalizedString(@"稍後提醒",nil)

// calendar
#define STR_1ON1 NSLocalizedString(@"1對1",nil)
#define STR_1ON2 NSLocalizedString(@"1對2",nil)
#define STR_1ON3 NSLocalizedString(@"1對3",nil)
#define STR_1ON4 NSLocalizedString(@"1對4",nil)
#define STR_1ON6 NSLocalizedString(@"小班制",nil)
#define STR_LOBBY_45 NSLocalizedString(@"知識大會堂",nil)
#define STR_LOBBY_10 NSLocalizedString(@"隨選快課10min",nil)
#define STR_LOBBY_20 NSLocalizedString(@"隨選快課20min",nil)
#define STR_POWER_SESSION NSLocalizedString(@"小班制立馬上",nil)

#define STR_RESERVE_RESULT NSLocalizedString(@"訂位結果",nil)
#define STR_RESERVE_SUCCESS NSLocalizedString(@"訂位成功",nil)
#define STR_RESERVE_FAIL NSLocalizedString(@"訂位失敗",nil)

#define STR_CANCEL_RESULT NSLocalizedString(@"取消訂位結果",nil)
#define STR_CANCEL_SUCCESS NSLocalizedString(@"取消成功",nil)
#define STR_CANCEL_FAIL NSLocalizedString(@"取消失敗",nil)

#define STR_REMAIN_LESSONS NSLocalizedString(@"剩餘堂數",nil)
#define STR_NO_LIMIT NSLocalizedString(@"無限制",nil)
#define STR_PLUS_1_ON_1 NSLocalizedString(@"加購 1 on 1",nil)
#define STR_I_KNOW NSLocalizedString(@"我知道了",nil)
#define STR_CONTINUE_RESERVE NSLocalizedString(@"繼續訂位",nil)
#define STR_COST_N_POINTS NSLocalizedString(@"扣 %@ 堂",nil)
#define STR_RETURN_N_POINTS NSLocalizedString(@"返還 %@ 堂",nil)
#define STR_CHARGE_CLASS_POINT NSLocalizedString(@"收取堂數 %@",nil)


#define STR_STILL_N_LESSONS NSLocalizedString(@"還有%lu項...",nil)

#define STR_RESERVED NSLocalizedString(@"已預訂課程",nil)
#define STR_RESERVED_CANNOT_CANCEL NSLocalizedString(@"已預訂課程無法取消",nil)
#define STR_RESERVED_2 NSLocalizedString(@"已有其他預訂課程",nil)
#define STR_RESERVED_CANNOT_CANCEL_2 NSLocalizedString(@"已有其他預訂課程無法取消",nil)
#define STR_NOT_OPENED NSLocalizedString(@"尚未開放訂位",nil)
#define STR_OVER_RESERVE_TIME NSLocalizedString(@"已超過訂位時間",nil)
#define STR_CANNOT_CANCEL NSLocalizedString(@"訂位後無法取消",nil)
#define STR_CANNOT_RESERVE_CONFLICT NSLocalizedString(@"已選擇同時段課程，請確認",nil)
#define STR_CANNOT_RESERVE_NO_ENOUGH_POINTS NSLocalizedString(@"您的剩餘堂數不足，請調整訂課，或撥02-33659999由專人為您服務。",nil)
#define STR_RESERVED_POWER_SESSION_HINT NSLocalizedString(@"提醒您：預約小班制課程，為了確保訂位，請於開課前20分鐘前報到，才會保證安排課程。",nil)


#define STR_CONFIRM_CANCEL_CONTENT NSLocalizedString(@"該時段您已訂\n%@\n請問要取消嗎?",nil)
#define STR_NOTICE NSLocalizedString(@"提醒您",nil)
#define STR_LESSONS_CONFLICT NSLocalizedString(@"同時段有重複的訂位\n請選擇一堂",nil)
#define STR_CONFIRM_NOWATTEND_TIMECONTENT NSLocalizedString(@"(%@ 後開課)",nil)
#define STR_CONFIRM_NOWATTEND_CONTENT NSLocalizedString(@"確認要訂位嗎?",nil)

#define STR_CANCEL_RESERVATION NSLocalizedString(@"取消訂位",nil)
#define STR_NOT_CANCEL_RESERVATION NSLocalizedString(@"不取消訂位",nil)
#define STR_RETURE_LESSON_POINT NSLocalizedString(@"%@\n返還%@堂",nil)
#define STR_CANCEL_SUCCESS NSLocalizedString(@"取消成功",nil)
#define STR_NOT_TAKE_TEST_BEFORE NSLocalizedString(@"親愛的會員您好，由於您尚未完成程度分析，TutorABC暫時無法為您安排符合您需求的教材與顧問，請您使用PC至官網完成程度分析後再進行預約。",nil)
#define STR_I_KNOW NSLocalizedString(@"我知道了",nil)
#define STR_CANCEL_ NSLocalizedString(@"取消訂位",nil)
#define STR_CONFIRM_CANCEL_RESERVE NSLocalizedString(@"養成學習頻率是很重要的，您確定要取消訂位？",nil)

#define STR_ADD_TO_LIST NSLocalizedString(@"加入訂位清單",nil)
#define STR_ALREADY_ADDED_TO_LIST NSLocalizedString(@"已加入訂位清單",nil)

// learning history
#define STR_FAIL_LEARNING_HISTORY_DATA_TITLE NSLocalizedString(@"學習歷程",nil)
#define STR_FAIL_MONTH_YEAR_DATA_CONTENT NSLocalizedString(@"月份資料錯誤",nil)
#define STR_FAIL_GET_MONTH_HISTORY NSLocalizedString(@"學習歷程資料錯誤",nil)
#define STR_FAIL_MAPPING_WEEK_DAY NSLocalizedString(@"Error to trans weekday",nil)
#define STR_CLASS_Attend NSLocalizedString(@"出席",nil)
#define STR_CLASS_Absent NSLocalizedString(@"未出席",nil)
#define STR_CONSULTANT_TITLE NSLocalizedString(@"顧問",nil)
#define STR_E01Msg01 NSLocalizedString(@"目前已過時間，期待您下次的回饋跟分享。", nil)
#define STR_E01Msg02 NSLocalizedString(@"因您未出席本堂課程，所以無法填寫本堂課後評鑑。", nil)
#define STR_E01Msg03 NSLocalizedString(@"本堂課的錄影檔將在24小時後提供，請您留意複習時間。", nil)
#define STR_E01Msg04 NSLocalizedString(@"這堂課的錄影檔品質不佳，請您撥打02-33659999，由我們為您提供更好的服務。", nil)
#define STR_E01Msg05 NSLocalizedString(@"親愛的客戶：App不支援該堂錄影檔格式，請使用電腦到官網複習該堂課。", nil)
#define STR_E01Msg06 NSLocalizedString(@"親愛的客戶：尚未達開放填寫時間。請稍後再填寫。", nil)

//classinfo
#define STR_CLASSINFO_ATTEND NSLocalizedString(@"已出席",nil)
#define STR_CLASSINFO_WAITATTEND NSLocalizedString(@"待出席",nil)
#define STR_CLASSINFO_NOTATTEND NSLocalizedString(@"未出席",nil)
#define STR_CLASSINFO_CANCELCONSULTANT NSLocalizedString(@"取消喜愛顧問",nil)
#define STR_CLASSINFO_ADDCONSULTANT NSLocalizedString(@"喜愛顧問",nil)

#define STR_CLASSINFO_ADDCONSULTANT_CONTENT NSLocalizedString(@"已成功加入喜愛顧問",nil)
#define STR_CLASSINFO_CANCELCONSULTANT_CONTENT NSLocalizedString(@"已成功取消喜愛顧問",nil)

#define STR_CLASSINFO_AFTERPREMTL NSLocalizedString(@"這堂課程已結束，24小時後即可複習錄影檔。",nil)



//attendnowalert
#define STR_ATTENDNOW_Preview NSLocalizedString(@"預習",nil)
#define STR_ATTENDNOW_CheckIn_Success NSLocalizedString(@"報到成功",nil)
#define STR_ATTENDNOW_CheckIn_Success_Content NSLocalizedString(@"您今日有預約一堂小班制課程。歡迎您於上課前1小時進行預習，並請準時進入諮詢室",nil)
#define STR_ATTENDNOW_InWaitingList NSLocalizedString(@"補位",nil)
#define STR_ATTENDNOW_InWaitingOK NSLocalizedString(@"我要補位",nil)
#define STR_ATTENDNOW_InWaiting NSLocalizedString(@"您未於開課前20分鐘進行報到，現在是補位時間，請進行補位",nil)
#define STR_ATTENDNOW_CheckIn NSLocalizedString(@"報到",nil)
#define STR_ATTENDNOW_OVER_RESERVE_TIME NSLocalizedString(@"(已超過訂位時間)",nil)
#define STR_ATTENDNOW_ALREADYOPENCLASS NSLocalizedString(@"(已開課)",nil)
#define STR_ATTENDNOW_SUCESSCONTENT NSLocalizedString(@"您已成功加入小班制課程，課前3分鐘開放進入諮詢室。歡迎您於上課前1小時進行預習，並請準時進入諮詢室。",nil)
#define STR_ATTENDNOW_SORRYCONTENT NSLocalizedString(@"現在小班制時段已額滿\n趕緊來預約知識大會堂吧!",nil)
#define STR_ATTENDNOW_SORRYTITLE NSLocalizedString(@"很抱歉",nil)
#define STR_ATTENDNOW_OTHERCLASSCONTENT NSLocalizedString(@"此時段已有其他預訂課程",nil)
#define STR_ATTENDNOW_TITLE NSLocalizedString(@"您立馬上課程資訊如下",nil)
#define STR_ATTENDNOW_CANCEL NSLocalizedString(@"取消",nil)
#define STR_ATTENDNOW_OK NSLocalizedString(@"確認",nil)
#define STR_ATTENDNOW_CLOSE NSLocalizedString(@"關閉",nil)
#define STR_ATTENDNOW_ATTEND NSLocalizedString(@"預約課程",nil)
//gotoclassalert
#define STR_NOGOTOGLASS_CONTENT_POWERSESSION NSLocalizedString(@"請於開課前5分鐘完成報到或補位，才能進入諮詢室。",nil)
#define STR_GOTOGLASS_CONTENT NSLocalizedString(@"你現在沒有可預習的課程",nil)
#define STR_NOGOTOGLASS_CONTENT NSLocalizedString(@"開課前3分鐘可進入教室\n請稍後再試",nil)
#define STR_NOGOTOGLASS_CONTENT_AFTER NSLocalizedString(@"這堂課程已結束，歡迎預約下一個時段課程，如有任何問題請撥02-33659999。謝謝您。",nil)
#define STR_ERRORGOTOGLASS_CONTENT NSLocalizedString(@"連線異常，請與客服聯繫02-33659999",nil)
#define STR_ERROR_CONTENT NSLocalizedString(@"連線異常，請重新再試",nil)
#define STR_ERROR_RATING_CONTENT NSLocalizedString(@"連線異常，請重新填寫評鑑",nil)
//classrating
#define STR_THANK_U NSLocalizedString(@"感謝您",nil)
#define STR_CLASSRATING_LEAVEALERT_TITLE NSLocalizedString(@"您的課後評鑑尚未填寫完成，是否確定離開?",nil)
#define STR_CLASSRATING_LEAVEALERT_CONTENT NSLocalizedString(@"是否確定離開?",nil)
#define STR_CLASSRATING_LEAVEALERT_LEFT NSLocalizedString(@"確定離開",nil)
#define STR_CLASSRATING_LEAVEALERT_RIGHT NSLocalizedString(@"繼續填寫",nil)
#define STR_CLASSRATING_COMMENT NSLocalizedString(@"對顧問的建議",nil)
#define STR_CLASSRATING_COMMENTGOOD NSLocalizedString(@"對顧問的讚美",nil)
#define STR_CLASSRATING_CLASSMATEENV NSLocalizedString(@"電腦環境（網路、音效)",nil)
#define STR_CLASSRATING_CLASSMATEBEH NSLocalizedString(@"同學上課表現",nil)
#define STR_CLASSRATING_GOOD_CLASSMATE NSLocalizedString(@"很好",nil)
#define STR_CLASSRATING_GOOD NSLocalizedString(@"良好",nil)
#define STR_CLASSRATING_NORMAL NSLocalizedString(@"尚可",nil)
#define STR_CLASSRATING_NORMAL_CLASSMATE NSLocalizedString(@"普通",nil)
#define STR_CLASSRATING_BAD_CLASSMATE NSLocalizedString(@"不好",nil)
#define STR_CLASSRATING_BAD NSLocalizedString(@"不佳",nil)
#define STR_CLASSRATING_PART5TITLE NSLocalizedString(@"建議與讚美",nil)
#define STR_CLASSRATING_PART5SEND NSLocalizedString(@"完成送出",nil)
#define STR_CLASSRATING_PART4TITLE NSLocalizedString(@"同學評比",nil)
#define STR_CLASSRATING_PART3TITLE NSLocalizedString(@"通訊評比",nil)
#define STR_CLASSRATING_PART3CONTENTTITLE NSLocalizedString(@"通訊狀態",nil)
#define STR_CLASSRATING_PART2TITLE NSLocalizedString(@"教材評比",nil)
#define STR_CLASSRATING_PART2CONTENT NSLocalizedString(@"難易度",nil)
#define STR_CLASSRATING_PART2_HARD NSLocalizedString(@"太難",nil)
#define STR_CLASSRATING_PART2_NORMAL NSLocalizedString(@"適中",nil)
#define STR_CLASSRATING_PART2_EASY NSLocalizedString(@"太簡單",nil)
#define STR_CLASSRATING_PART1TITLE NSLocalizedString(@"教學評比",nil)

#define STR_CLASSRATING_PART1_FAST NSLocalizedString(@"太快",nil)
#define STR_CLASSRATING_PART1_NORMAL NSLocalizedString(@"適中",nil)
#define STR_CLASSRATING_PART1_SLOW NSLocalizedString(@"太慢",nil)

#define STR_CLASSRATING_PART1_2_TITLE NSLocalizedString(@"講話速度",nil)
#define STR_CLASSRATING_PART1_3_TITLE NSLocalizedString(@"時間分配",nil)
#define STR_CLASSRATING_PART1_4_TITLE NSLocalizedString(@"教學技巧",nil)
#define STR_CLASSRATING_PART1_5_TITLE NSLocalizedString(@"教學態度",nil)

#define STR_CLASSRATING_MTL_TITLE NSLocalizedString(@"請輸入希望加強教材的原因",nil)
#define STR_CLASSRATING_CLASSMATESECOND_TITLE NSLocalizedString(@"請選擇同學%@%@%@的狀況",nil)
#define STR_CLASSRATING_CHOOSESECOND_TITLE NSLocalizedString(@"請選擇%@%@的狀況",nil)


#define STR_CLASSRATING_NOTCOMPLETE_CONTENT NSLocalizedString(@"你有未填寫完成的項目\n請您再次確認",nil)
#define STR_CLASSRATING_COMPLETE_CONTENT NSLocalizedString(@"感謝你的回饋，你的寶貴建議將成為提升課程品質的重要依據。",nil)
//showfirstDeviceTest
#define STR_FIRSTDEVICETEST_CONTENT NSLocalizedString(@"您是第一次使用這台裝置上課，建議先測試耳機麥克風，將會使你擁有更良好的課程體驗",nil)
#define STR_FIRSTDEVICETEST_LEFT NSLocalizedString(@"下次測試",nil)
#define STR_FIRSTDEVICETEST_RIGHT NSLocalizedString(@"現在去測試",nil)
//leftview
#define STR_FAVORITE_TITLE NSLocalizedString(@"喜歡我們的課程嗎",nil)
#define STR_FAVORITE_CONTENT NSLocalizedString(@"請來電0800-66-66-80，將有專人為你規劃專屬課程！",nil)
#define STR_FAVORITE_CONTENT_DEMO_SESSION NSLocalizedString(@"請來電0800-66-66-80\n由專人為您開通",nil)
#define STR_PLEASE_LOGIN NSLocalizedString(@"請登入您的學習帳號",nil)
// no network
#define STR_NO_NETWORK_TITLE NSLocalizedString(@"溫馨提示",nil)
#define STR_NO_NETWORK_CONTENT NSLocalizedString(@"請檢查你的網路連線",nil)
#define STR_BTN_I_SEE NSLocalizedString(@"我知道了",nil)

// session room
#define STR_ENTER_SESSION_WITHOUT_CHECKIN NSLocalizedString(@"你已錯過報到及補位時間，無法進入諮詢室。",nil)
#define STR_ENTER_SESSION_JoinNet NSLocalizedString(@"很抱歉 App不支援JoinNet教室，請與客服聯繫02-33659999或改用電腦版上課。",nil)
//// weekday
//#define DIC_WEEKDAY @{\
//@"Sun" : @"週日",\
//@"Mon" : @"週一",\
//@"Tue" : @"週二",\
//@"Wed" : @"週三",\
//@"Thu" : @"週四",\
//@"Fri" : @"週五",\
//@"Sat" : @"週六",\
//};

// setting
#define STR_REMINDER_5_HR_BEFORE_SESSION_START NSLocalizedString(@"上課前5小時提醒", nil)
#define STR_REMINDER_1_HR_BEFORE_SESSION_START NSLocalizedString(@"上課前1小時提醒", nil)
#define STR_REMINDER_15_MIN_BEFORE_SESSION_START NSLocalizedString(@"上課前15分鐘提醒", nil)
#define STR_REMINDER_65_MIN_CHECK_IN NSLocalizedString(@"上課前65分鐘報到提醒", nil)

#define STR_DEVICE_TEST NSLocalizedString(@"裝置測試", nil)
#define STR_ABOUT_TUTORABC NSLocalizedString(@"關於TutorABC", nil)
#define STR_VERSION NSLocalizedString(@"版本", nil)
#define STR_ACCOUNT_INFO NSLocalizedString(@"帳號資訊", nil)
#define STR_LOGOUT NSLocalizedString(@"登出", nil)

#define STR_MESSAGE_CONFIRM_LOGOUT NSLocalizedString(@"確定要登出嗎？", nil)
#define STR_YES NSLocalizedString(@"確定", nil)

#define STR_UNTEST NSLocalizedString(@"●未測試", nil)
#define STR_TEST_PASS NSLocalizedString(@"測試通過", nil)
#define STR_TEST_FAIL NSLocalizedString(@"測試不通過", nil)

#define STR_SETTING NSLocalizedString(@"設定", nil)

// device test
#define STR_MESSAGE_CONFIRM_QUIT_DEVICE_TEST NSLocalizedString(@"確定要退出裝置測試嗎？", nil)
#define STR_ASK_PERMISSION_FOR_MICROPHONE NSLocalizedString(@"請授權取用您的麥克風", nil)

#define STR_CANCEL NSLocalizedString(@"取消", nil)
#define STR_OK NSLocalizedString(@"確認", nil)

// vocabulary
#define STR_COUNT_OF_VOCABULARY NSLocalizedString(@"共%lu個單字", nil)
#define STR_EMPTY_VOCABULARY NSLocalizedString(@"共0個單字", nil)

//#define DIC_WEEKDAY @{\
//@"Sun" : @"週日",\
//@"Mon" : @"週一",\
//@"Tue" : @"週二",\
//@"Wed" : @"週三",\
//@"Thu" : @"週四",\
//@"Fri" : @"週五",\
//@"Sat" : @"週六",\
//};

#define STR_RETRY_LATER NSLocalizedString(@"請稍後再試", nil)

#endif
