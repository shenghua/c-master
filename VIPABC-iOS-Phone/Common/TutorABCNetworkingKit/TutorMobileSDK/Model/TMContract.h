//
//  TMContract.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/8/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TMProductStatus_Normal = 1,
    TMProductStatus_Special = 2,
    TMProductStatus_Unlimit = 3,
    TMProductStatus_Unlimit_All_Life = 4,
    TMProductStatus_Set = 5,
    TMProductStatus_Power_Session = 6,
    TMProductStatus_1on1 = 101
} TMProductStatus;

@interface TMContract : NSObject

@property (nonatomic, assign) NSInteger clientSn;

@property (nonatomic, assign) TMProductStatus productStatus;

@property (nonatomic, assign) NSInteger paymentType;

@property (nonatomic, assign) NSInteger absentBookingSessions;

@property (nonatomic, assign) float contractTotalSessions;

@property (nonatomic, assign) NSInteger refundBookingSessions;

@property (nonatomic, assign) BOOL isInService;

@property (nonatomic, assign) BOOL isOneOnOneContract;

@property (nonatomic, assign) NSInteger pastOneOnOneBookingSessions;

@property (nonatomic, assign) NSInteger futureBookingSessions;

@property (nonatomic, assign) long long serviceEndDate;

@property (nonatomic, assign) NSInteger videoUsedSessions;

@property (nonatomic, assign) float availableSessions;

@property (nonatomic, assign) NSInteger sessionBonus;

@property (nonatomic, assign) NSInteger contractSn;

@property (nonatomic, assign) NSInteger pastLobbyBookingSessions;

@property (nonatomic, assign) NSInteger lateBookingSessions;

@property (nonatomic, assign) long long serviceStartDate;

@property (nonatomic, copy) NSString *productName;

@property (nonatomic, assign) NSInteger pastBookingSessions;

@property (nonatomic, assign) float sessions;

@property (nonatomic, assign) NSInteger productSn;

@end
