//
//  TMSessionUtil.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/14/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import "TMClassUtil.h"
#import "TMNNetworkLogicController.h"
#import "TMTask.h"
#import "ErrorCodeFromAPI.h"
#import "LocalizedString.h"

@interface TMClassUtil ()

@property (nonatomic,strong) NSMutableDictionary *cachedDict;
@property (nonatomic,strong) NSMutableDictionary *tasks;

@end

@implementation TMClassUtil

+ (instancetype)sharedUtil {
    static TMClassUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
        sharedUtil.cachedDict = [NSMutableDictionary dictionary];
        sharedUtil.tasks = [NSMutableDictionary dictionary];
        sharedUtil.favoriteConsultants = [NSMutableDictionary dictionary];
    });
    return sharedUtil;
}

-(TMClassInfo *)getClassWithSn:(NSString *)sn andBlock:(void (^)(NSError *, TMClassInfo *, BOOL))block{
    if(sn == nil){
        block([NSError errorWithDomain:STR_ERROR_DOMAIN code:kInAPPErrorCode userInfo:@{NSLocalizedDescriptionKey:@"SN is nil"}],nil,NO);
        return nil;
    }
    
    BOOL alreadyReturn_ = NO;
    
    TMClassInfo *class = [_cachedDict valueForKey:sn];
    if(class){
        if(([NSDate date].timeIntervalSince1970 - class.updatedTime) <30*60){
            alreadyReturn_ = YES;
            
            if([[_favoriteConsultants allKeys] containsObject:class.consultantSn]){
                NSNumber *isFav = [_favoriteConsultants valueForKey:class.consultantSn];
                class.followConsultant = isFav.boolValue;
            }

            
            block(nil,class,alreadyReturn_);
            return class;
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
        [networkLogicController getClassInfoWithSn:sn successBlock:^(TMClassInfo *class) {
            
            class.updatedTime = [[NSDate date] timeIntervalSince1970];
            [_cachedDict setObject:class forKey:class.sessionSn];
            
            TMTask *task = [_tasks valueForKey:sn];
            while (task.taskQueue.count >0) {
                void(^blockInQueue)(NSError *, TMClassInfo *, BOOL) = [task.taskQueue dequeue];
                blockInQueue(nil,class,alreadyReturn_);
            }

        } failedBlock:^(NSError *error, id responseObject) {
  
            TMTask *task = [_tasks valueForKey:sn];
            while (task.taskQueue.count >0) {
                void(^blockInQueue)(NSError *, TMClassInfo *, BOOL) = [task.taskQueue dequeue];
                blockInQueue(error,nil,NO);
            }

        }];
    }
    
    return class;

}

-(void)clean{
    self.cachedDict = [NSMutableDictionary dictionary];
    self.tasks = [NSMutableDictionary dictionary];
    self.favoriteConsultants = [NSMutableDictionary dictionary];
}

@end
