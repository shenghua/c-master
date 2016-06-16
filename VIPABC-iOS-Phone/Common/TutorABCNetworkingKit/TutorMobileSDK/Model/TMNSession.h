//
//  TMNSession.h
//  TutorMobileNative
//
//  Created by Oxy Hsing_邢傑 on 8/31/15.
//  Copyright (c) 2015 TutorABC, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNConstants.h"

@interface TMNSession : NSObject
/**
 *  會員編號
 */
@property (nonatomic, copy) NSString * clientSn;
@property (nonatomic, copy) NSNumber * brandId;
@property (nonatomic, copy) NSNumber * smallClassSessionType;
@property (nonatomic, copy) NSString * clientEmail;
@property (nonatomic, copy) NSString * fromDevice;
@property (nonatomic, assign) TMNUserType *userType;

@end