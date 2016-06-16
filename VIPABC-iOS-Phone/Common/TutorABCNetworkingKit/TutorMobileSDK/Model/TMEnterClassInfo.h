//
//  TMEnterClassInfo.h
//  TutorMobile
//
//  Created by AbbyHsu on 2015/10/23.
//  Copyright © 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMRoomInfo.h"
@interface TMEnterClassInfo : NSObject
@property (nonatomic, assign)  NSInteger statuscode;
@property (nonatomic, assign)  BOOL canEnter;
@property (nonatomic, strong) TMRoomInfo *roominfo;
@end
