//
//  TMContractUtil.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/8/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMContract.h"

#define kContractUpdateNotification @"onContractUpdate"
#define NSStringFromInteger(a) @(a).stringValue

typedef enum : NSUInteger {
    TMContractType_Normal,
    TMContractType_Unlimit,
    TMContractType_Unlimit_1on1,
    TMContractType_PowerSession,
    TMContractType_PowerSession_1on1,
    TMContractType_Other
} TMContractType;

@interface TMContractUtil : NSObject

@property (nonatomic,assign) TMContractType contractType;
@property (nonatomic,strong) NSDictionary *cachedDict;
@property (nonatomic,strong) NSArray *cachedContracts;

+(instancetype)sharedUtil;
-(void) syncContractsWithResultBlock:(void(^)(NSError *error, NSArray *contracts, NSDictionary *contractsDict))block;
-(void) forceSyncContractsWithResultBlock:(void(^)(NSError *error, NSArray *lessons, NSDictionary *contracts))block;

@end
