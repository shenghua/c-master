//
//  TutorLog.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/6/30.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#ifndef TutorMobile_TutorLog_h
#define TutorMobile_TutorLog_h

//#import <CocoaLumberjack/CocoaLumberjack.h>

//#ifdef DEBUG
//static const DDLogLevel ddLogLevel = DDLogLevelDebug;
//#else
//static const DDLogLevel ddLogLevel = DDLogLevelOff;
//#endif

#ifdef DEBUG
#   define DDLogDebug(fmt, ...) NSLog((@"[%s][%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DDLogVerbose(fmt, ...) NSLog((@"[%s][%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DDLogError(fmt, ...) NSLog((@"[%s][%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DDLogDebug(...)
#   define DDLogVerbose(fmt, ...)
#   define DDLogError(fmt, ...)
#endif

#endif
