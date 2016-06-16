//
//  TMSessionUtil.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/14/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMClassInfo.h"


@interface TMClassUtil : NSObject

@property (strong,nonatomic) NSMutableDictionary *favoriteConsultants;

+ (instancetype)sharedUtil;

-(TMClassInfo *) getClassWithSn:(NSString *)sn andBlock:(void(^)(NSError *error, TMClassInfo *classinfo, BOOL alreadyReturn))block;
-(void)clean;

@end
