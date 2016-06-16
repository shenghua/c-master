//
//  TMNewbieUtil.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/28/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import "TMNewbieUtil.h"
#import "TMNNetworkLogicController.h"

@interface TMNewbieUtil ()

@property (nonatomic,strong) TMNewbieResponse *response;

@end

@implementation TMNewbieUtil

+ (instancetype)sharedUtil {
    static TMNewbieUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

-(void) checkNewbieWithBlock:(void(^)(NSError *error, TMNewbieResponse *newbieResponse))block{

    
    TMNewbieResponse *response = _response;
    if(response){
        if(!response.isNewbie){
            block(nil,response);
            return;
        }
        
        if(([NSDate date].timeIntervalSince1970 - response.updatedTime) < 600){
            block(nil,response);
            return;
        }
    }
    TMNNetworkLogicController *networkLogicController = [TMNNetworkLogicController sharedInstance];
    [networkLogicController checkNewbieWithSuccessBlock:^(TMNewbieResponse *object) {
        object.updatedTime = [NSDate date].timeIntervalSince1970;
        _response = object;
        block(nil,object);
        return;
    } failedBlock:^(NSError *error, id responseObject) {
        block(error,nil);
        return;
    }];
}

-(void) clear{
    _response = nil;
}

@end
