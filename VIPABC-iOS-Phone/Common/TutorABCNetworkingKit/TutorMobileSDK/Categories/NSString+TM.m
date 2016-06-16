//
//  NSString+TM.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 9/23/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import "NSString+TM.h"
#import "TMConfigUtil.h"

@implementation NSString (TM)

+(NSString *) stringWithSessionType:(TMNClassSessionType)type{
    
    NSString *str = [[TMConfigUtil sharedUtil] strWithSessionType:type];
    if(str){
        return str;
    }
    
    switch (type) {
        case TMNClassSessionType_1on1:
            return STR_1ON1;
        case TMNClassSessionType_1on2:
            return STR_1ON2;
        case TMNClassSessionType_1on3:
            return STR_1ON3;
        case TMNClassSessionType_1on4:
            return STR_1ON4;
        case TMNClassSessionType_1on6:
            return STR_1ON6;
        case TMNClassSessionType_Lobby10:
            return STR_LOBBY_10;
        case TMNClassSessionType_Lobby20:
            return STR_LOBBY_20;
        case TMNClassSessionType_Lobby45:
            return STR_LOBBY_45;
        case TMNClassSessionType_PowerSession:
            return STR_POWER_SESSION;
        default:
            return @"";
    }
}

+(NSString *) engStringWithSessionType:(TMNClassSessionType)type{
    
    NSString *str = [[TMConfigUtil sharedUtil] engStrWithSessionType:type];
    if(str){
        return str;
    }
    
    switch (type) {
        case TMNClassSessionType_1on1:
            return STR_1ON1;
        case TMNClassSessionType_1on2:
            return STR_1ON2;
        case TMNClassSessionType_1on3:
            return STR_1ON3;
        case TMNClassSessionType_1on4:
            return STR_1ON4;
        case TMNClassSessionType_1on6:
            return STR_1ON6;
        case TMNClassSessionType_Lobby10:
            return STR_LOBBY_10;
        case TMNClassSessionType_Lobby20:
            return STR_LOBBY_20;
        case TMNClassSessionType_Lobby45:
            return STR_LOBBY_45;
        case TMNClassSessionType_PowerSession:
            return STR_POWER_SESSION;
        default:
            return @"";
    }
}

+(NSString *) stringWithSessionTypeNumber:(NSNumber *)number{
    return [NSString stringWithSessionType:number.integerValue];
}

@end
