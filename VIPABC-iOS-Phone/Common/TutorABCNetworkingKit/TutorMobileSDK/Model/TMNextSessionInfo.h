//
//  TMNextSessionInfo.h
//  TutorMobile
//
//  Created by AbbyHsu on 2015/10/28.
//  Copyright © 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMNextSessionInfo : NSObject
@property (nonatomic, assign)  NSString *sessionSn;
@property (nonatomic, assign)  BOOL canCheckIn;
@property (nonatomic, assign)  BOOL canInWaitingList;
@property (nonatomic, assign)  BOOL canView;
@property (nonatomic, assign)  BOOL checkInStatus;
@property (nonatomic, assign)  long int sessionBeginTime;
@property (nonatomic, assign)  int classType;
@property (nonatomic, assign)  long int expiredTime;
@end
