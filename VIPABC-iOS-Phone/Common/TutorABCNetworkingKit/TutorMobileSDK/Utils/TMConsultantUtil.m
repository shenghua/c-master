//
//  TMConsultantUtil.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/14/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import "TMConsultantUtil.h"
#import "NSDate+TM.h"
#import "TMNNetworkLogicController.h"
#import "TMConsultant.h"
#import "NSMutableArray+TM.h"
#import "TMTask.h"
#import "ErrorCodeFromAPI.h"


@interface TMConsultantUtil ()

@property (nonatomic,strong) NSMutableDictionary *cachedDict;
@property (nonatomic,strong) NSMutableDictionary *tasks;

@end

@implementation TMConsultantUtil

+ (instancetype)sharedUtil {
    static TMConsultantUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
        sharedUtil.cachedDict = [NSMutableDictionary dictionary];
        sharedUtil.tasks = [NSMutableDictionary dictionary];
    });
    return sharedUtil;
}

-(TMConsultant *) getConsultantWithSn:(NSString *)sn andBlock:(void(^)(NSError *error, TMConsultant *consultant, BOOL alreadyReturn))block{
    
    if(sn == nil){
        block([NSError errorWithDomain:STR_ERROR_DOMAIN code:kInAPPErrorCode userInfo:@{NSLocalizedDescriptionKey:@"SN is nil"}],nil,NO);
        return nil;
    }
    
    BOOL alreadyReturn_ = NO;
    
    TMConsultant *consultant = [_cachedDict valueForKey:sn];
    if(consultant){
        if(([NSDate date].timeIntervalSince1970 - consultant.updatedTime) <30*60){
            alreadyReturn_ = YES;
            block(nil,consultant,alreadyReturn_);
            return consultant;
        }
    }
    
    TMTask *task = [_tasks valueForKey:sn];
    
    if(!task){
        task = [[TMTask alloc] init];
        [_tasks setValue:task forKey:sn];
    }
    
    [task.taskQueue enqueue:block];
    
    if(task.taskQueue.count >1){

    }else{
        TMNNetworkLogicController *networkLogicController = [TMNNetworkLogicController sharedInstance];
        [networkLogicController getConsultantInfoWithSn:sn successBlock:^(TMConsultant *consultant) {
            
            consultant.updatedTime = [[NSDate date] timeIntervalSince1970];
            
            [_cachedDict setObject:consultant forKey:@(consultant.consultantSn).stringValue];
            
            TMTask *task = [_tasks valueForKey:sn];
            while (task.taskQueue.count >0) {
                void(^blockInQueue)(NSError *error, TMConsultant *consultant, BOOL alreadyReturn) = [task.taskQueue dequeue];
                blockInQueue(nil,consultant,alreadyReturn_);
            }
            
        } failedBlock:^(NSError *error, id responseObject) {
            TMTask *task = [_tasks valueForKey:sn];
            while (task.taskQueue.count >0) {
                void(^blockInQueue)(NSError *error, TMConsultant *consultant, BOOL alreadyReturn) = [task.taskQueue dequeue];
                blockInQueue(error,nil,NO);
            }
        }];
    }

    return consultant;
}


@end

