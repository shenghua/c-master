//
//  WbObjectFactory.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/18.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionWhiteboardObject.h"
#import "WbObject.h"

@interface WbObjectFactory : NSObject
// For live session
+ (WbObject *)createLiveWbObject:(WhiteboardObject *)wo;

// For recorded session
+ (WbObject *)createRecordedWbObject:(SessionWhiteboardObject *)wo;

+ (SessionWhiteboardObject *)getRecordedWbObjectFromLiveWbObject:(WhiteboardObject *)wo;
@end
