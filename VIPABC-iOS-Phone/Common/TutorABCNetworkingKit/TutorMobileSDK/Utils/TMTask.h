//
//  TMTask.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/20/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+TM.h"

@interface TMTask : NSObject

@property (nonatomic,assign) BOOL alreadyReturn;
@property (nonatomic,strong) NSMutableArray *taskQueue;

@end
