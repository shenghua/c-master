//
//  SessionConstants.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/19.
//
//

#ifndef SessionConstants_h
#define SessionConstants_h

// Recorded Session Events
#define kRecordedSessionEvent_Init         @"a"
#define kRecordedSessionEvent_Logout       @"o"
#define kRecordedSessionEvent_Record       @"r"
#define kRecordedSessionEvent_Chat         @"c"
#define kRecordedSessionEvent_Time         @"t"
#define kRecordedSessionEvent_ClapHands    @"h"
#define kRecordedSessionEvent_Page         @"p"
#define kRecordedSessionEvent_Shape        @"s"
#define kRecordedSessionEvent_DeleteShape  @"d"
#define kRecordedSessionEvent_ClearShapes  @"l"
#define kRecordedSessionEvent_Mouse        @"m"
#define kRecordedSessionEvent_Pointer      @"x"

// Session Room Types
typedef enum _SessionRoomType {
    SessionRoomType_Normal = 1,
    SessionRoomType_Webcast1 = 2,
    SessionRoomType_10MinShortSession = 24,
    SessionRoomType_20MinShortSession = 26,
    
    SessionRoomType_TutorGlassWebcast = 33,
    SessionRoomType_TutorGlass = 35, // both consultant & student can talk
} SessionRoomType;

#define kPresenterPublishName @"presenter"

#define kOsIos @"13"

#define kLogLogin   @"Login"
#define kLogLogout  @"Logout"
#define kLogFmsRelay @"FMS Relay"
#define kLogLoginFail @"LoginFail"
#define kLogReconnectSession @"Reconnect"
#define kLogMicVol @"Mic Vol"
#define kLogMicMute @"Mic Mute"
#define kLogMicGain @"Mic Gain"
#define kLogSpeakerVol @"Speaker Vol"
#define kLogSpeakerMute @"Speaker Mute"
#define kLogInputParams @"Input Params"

#endif /* SessionConstants_h */
