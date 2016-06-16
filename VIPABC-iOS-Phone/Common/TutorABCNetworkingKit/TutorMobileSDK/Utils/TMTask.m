//
//  TMTask.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/20/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import "TMTask.h"

@implementation TMTask

-(instancetype)init{
    self = [super init];
    if(self){
        self.taskQueue = [NSMutableArray array];
    }
    return self;
}

@end
