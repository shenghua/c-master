//
//  TMRoomInfo.h
//  TutorMobile
//
//  Created by AbbyHsu on 2015/10/23.
//  Copyright © 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMRoomInfo : NSObject



@property (nonatomic, copy) NSString *Date;

@property (nonatomic, copy) NSString *duration;

@property (nonatomic, copy) NSString *maxMember;

@property (nonatomic, copy) NSString *consultantName;

@property (nonatomic, copy) NSString *materialSn;

@property (nonatomic, copy) NSString *materialDescription;

@property (nonatomic, copy) NSString *materialTitle;

@property (nonatomic, copy) NSString *consultantSn;

@property (nonatomic, copy) NSString *consultImage;

@property (nonatomic, copy) NSString *materialImage;

@property (nonatomic, copy) NSString *roomNumber;

@property (nonatomic, assign) int sessions;

@property (nonatomic, assign) int sessionRoomId;

@property (nonatomic, assign) int randStr;

@property (nonatomic, assign) int classType;

@property (nonatomic, assign) int compStatus;

@property (nonatomic, assign) int ratingRecount;

@property (nonatomic, assign) int clientSn;
@end
