//
//  TMConfigUtil.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 10/20/15.
//  Copyright © 2015 TutorABC. All rights reserved.
//

#import "TMConfigUtil.h"
#import "TMNNetworkLogicController.h"
#import "MJExtension.h"

#define kConfigKey @"config_json"
#define kLocalJson @"{\"lang\": {\"zhTW\": {\"1\": \"1對1\",\"2\": \"1對2\",\"3\": \"1對3\",\"4\": \"1對4\",\"6\": \"小班制\",\"10\": \"隨選快課10min\",\"20\": \"隨選快課20min\",\"91\": \"小班制立馬上\",\"99\": \"知識大會堂\"},\"en\": {\"1\": \"One-on-one Session\",\"2\": \"One-on-two Session\",\"3\": \"One-on-three Session\",\"4\": \"One-on-four Session\",\"6\": \"Regular Session\",\"10\": \"Quick Session 10min\",\"20\": \"Quick Session 20min\",\"91\": \"Regular Session Now\",\"99\": \"Special Session\"}},\"maxReservation\": 10}"

@interface TMConfigUtil ()

@property (strong,nonatomic) TMConfig *config;

@end

@implementation TMConfigUtil

+ (instancetype)sharedUtil {
    static TMConfigUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

-(void) syncWithBlock:(void(^)(NSError *, id))block{
    TMNNetworkLogicController *networkLogicController = [TMNNetworkLogicController sharedInstance];
    [networkLogicController getConfigWithSuccessBlock:^(TMConfig *object) {
        
        [[NSUserDefaults standardUserDefaults] setObject:object.keyValues forKey:kConfigKey];
        
        if(block){
            block(nil,object);
        }
        
    } failedBlock:^(NSError *error, id responseObject) {
        if(block){
            block(error,nil);
        }
    }];
}

-(NSString *) strWithSessionType:(TMNClassSessionType) type{
    if(!_config){
        if([[NSUserDefaults standardUserDefaults] objectForKey:kConfigKey]){
            _config = [TMConfig objectWithKeyValues:[[NSUserDefaults standardUserDefaults] objectForKey:kConfigKey]];
        }
    }
    
    if(!_config){
        _config = [TMConfig objectWithKeyValues:kLocalJson];
    }
    
    TMLang *lang= _config.lang;
    
    if(lang && lang.zhTW){
    
        NSString *v = [lang.zhTW objectForKey:@(type).stringValue];
        
        return v;
    }
    
    return nil;
}

-(NSString *) engStrWithSessionType:(TMNClassSessionType) type{
    if(!_config){
        if([[NSUserDefaults standardUserDefaults] objectForKey:kConfigKey]){
            _config = [TMConfig objectWithKeyValues:[[NSUserDefaults standardUserDefaults] objectForKey:kConfigKey]];
        }
    }
    
    if(!_config){
        _config = [TMConfig objectWithKeyValues:kLocalJson];
    }
    
    TMLang *lang= _config.lang;
    
    if(lang && lang.en){
        
        NSString *v = [lang.en objectForKey:@(type).stringValue];
        
        return v;
    }
    
    return nil;
}

@end
