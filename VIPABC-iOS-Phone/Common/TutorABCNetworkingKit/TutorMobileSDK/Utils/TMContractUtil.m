//
//  TMContractUtil.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/8/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import "TMContractUtil.h"
#import "TMNNetworkLogicController.h"
#import "NSString+TM.h"
#import "NSMutableArray+TM.h"
#import "NSDate+TM.h"


@interface TMContractUtil ()

@property (nonatomic,assign) long long cachedTimestamp;
@property (nonatomic,strong) NSMutableArray *taskQueue;

@end

@implementation TMContractUtil


+ (instancetype)sharedUtil {
    static TMContractUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
        sharedUtil.taskQueue = [NSMutableArray array];
    });
    return sharedUtil;
} 

-(void) syncContractsWithResultBlock:(void(^)(NSError *error, NSArray *lessons, NSDictionary *contracts))block{
    
    __weak typeof(self) weakSelf = self;
    static NSInteger kCachedTime = 10*1000;

    if([NSDate date].unixTimestamp-_cachedTimestamp > kCachedTime){
        
        [_taskQueue enqueue:block];
        
        if(_taskQueue.count >1){
            
        }else{
            TMNNetworkLogicController *networkLogicController = [TMNNetworkLogicController sharedInstance];
            [networkLogicController getContractInfoWithSuccessBlock:^(NSArray *responseArray) {
                typeof(weakSelf) self = weakSelf;
                
                _cachedTimestamp = [NSDate date].unixTimestamp;
                _cachedContracts = [responseArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isInService == true"]];
                [self update];
                [[NSNotificationCenter defaultCenter] postNotificationName:kContractUpdateNotification object:self];
                
                while (_taskQueue.count >0) {
                    void(^blockInQueue)(NSError *error, NSArray *lessons, NSDictionary *contracts) = [_taskQueue dequeue];
                    blockInQueue(nil,_cachedContracts,_cachedDict);
                }
                
                
            } failedBlock:^(NSError *error, id responseObject) {
                
                _cachedContracts = @[];
                while (_taskQueue.count >0) {
                    void(^blockInQueue)(NSError *error, NSArray *lessons, NSDictionary *contracts) = [_taskQueue dequeue];
                    blockInQueue(error,nil,nil);
                }
            }];
        }
        
    }else{
        return block(nil,_cachedContracts,_cachedDict);
    }
    
}

-(void) forceSyncContractsWithResultBlock:(void(^)(NSError *error, NSArray *lessons, NSDictionary *contracts))block{

    __weak typeof(self) weakSelf = self;
    TMNNetworkLogicController *networkLogicController = [TMNNetworkLogicController sharedInstance];
    [networkLogicController getContractInfoWithSuccessBlock:^(NSArray *responseArray) {
        typeof(weakSelf) self = weakSelf;
        
        _cachedTimestamp = [NSDate date].unixTimestamp;
        _cachedContracts = [responseArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isInService == true"]];
        [self update];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kContractUpdateNotification object:self];
        block(nil,_cachedContracts,_cachedDict);
    } failedBlock:^(NSError *error, id responseObject) {
        
        _cachedContracts = @[];
        
        block(error,nil,nil);
    }];
}

-(void) update{
    _contractType = [self updateContractType];
}

-(TMContractType)updateContractType{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if(_cachedContracts.count >1){
        for (TMContract *contract in _cachedContracts) {
            if(contract.availableSessions == 0){
                continue;
            }
            
            if(contract.isOneOnOneContract){
                contract.productStatus = TMProductStatus_1on1;
            }
            
            if([[dict allKeys] containsObject:@(contract.productStatus).stringValue]){
                NSMutableArray *array = [dict valueForKey:@(contract.productStatus).stringValue];
                [array addObject:contract];
            }else{
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:contract];
                [dict setValue:array forKey:@(contract.productStatus).stringValue];
            }
        }
        
        _cachedDict = dict;
        
        if([[dict allKeys] containsObject:NSStringFromInteger(TMProductStatus_Unlimit)]){
            
            if([[dict allKeys] containsObject:NSStringFromInteger(TMProductStatus_1on1)]){
                return TMContractType_Unlimit_1on1;
            }else{
                return TMContractType_Unlimit;
            }
        }
        
        if([[dict allKeys] containsObject:NSStringFromInteger(TMProductStatus_Power_Session)]){
            
            if([[dict allKeys] containsObject:NSStringFromInteger(TMProductStatus_1on1)]){
                return TMContractType_PowerSession_1on1;
            }else{
                return TMContractType_PowerSession;
            }
            
        }
    }
    
    if(_cachedContracts.count == 1){
        TMContract *contract = _cachedContracts[0];
        
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:contract];
        [dict setValue:array forKey:@(contract.productStatus).stringValue];
        _cachedDict = dict;
        
        if(contract.productStatus ==TMProductStatus_Normal){
            return TMContractType_Normal;
        }
        
        if(contract.productStatus ==TMProductStatus_Special){
            return TMContractType_Other;
        }
        
        if(contract.productStatus ==TMProductStatus_Set){
            return TMContractType_Other;
        }
        
        if(contract.productStatus ==TMProductStatus_Unlimit){
            return TMContractType_Unlimit;
        }
        
        if(contract.productStatus ==TMProductStatus_Unlimit_All_Life){
            return TMContractType_Unlimit;
        }
        
        if(contract.productStatus ==TMProductStatus_Power_Session){
            return TMContractType_PowerSession;
        }
    }
    
    return TMContractType_Other;
}

@end

