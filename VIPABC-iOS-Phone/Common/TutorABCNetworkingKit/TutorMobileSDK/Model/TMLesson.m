//
//  TMLessons.m
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 9/18/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import "TMLesson.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDate+TM.h"
#import "NSString+TM.h"
#import "TMContractUtil.h"

@implementation TMLesson

+(TMLesson *) lessonWithPlanDummyLesson:(TMPlanDummyLesson *) lesson{
    TMLesson *newLesson = [[TMLesson alloc] init];
    newLesson.sessionType = lesson.sessionType;
    newLesson.endTime = lesson.endTime;
    newLesson.usePoints = lesson.usePoints;
    newLesson.status = lesson.status;
    newLesson.startTime = lesson.startTime;
    newLesson.attendSn = lesson.attendSn;
    newLesson.canCancel = lesson.canCancel;
    newLesson.sessionSn = lesson.sessionSn;

    if(lesson.title && [lesson.title isEqualToString:@"None"]){
        lesson.title = nil;
    }
    
    if(lesson.title || lesson.materialSn || lesson.consultantSn || lesson.lobbySn){
        Classdetail *detail = [[Classdetail alloc] init];
        detail.title = lesson.title;
        detail.materialSn = lesson.materialSn.integerValue;
        detail.titleEN = lesson.titleEN;
        detail.consultantSn = lesson.consultantSn.integerValue;
        detail.lobbySn = lesson.lobbySn.integerValue;
        
        newLesson.classDetail = detail;
    }
    
    return newLesson;
}

-(BOOL) isConflictWithLesson:(TMLesson *)lesson{
    if(!lesson) return false;

    if(lesson.endTime >= self.endTime){
        if(self.endTime > lesson.startTime){
            return YES;
        }else{
            return NO;
        }
    }else{
        if(lesson.endTime > self.startTime){
            return YES;
        }else{
            return NO;
        }
    }
}

-(NSString *)hashString{
    if(_classDetail){
        if(self.classDetail.lobbySn){
            return NSStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, [NSString stringWithFormat:@"%f_%lu",self.startTime,(long)self.classDetail.lobbySn]);
        }
        
        if(self.classDetail.title){
            return NSStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, [NSString stringWithFormat:@"%f_%@",self.startTime,self.classDetail.title]);
        }
    }
    
    return NSStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, [NSString stringWithFormat:@"%f_%lu",self.startTime,(long)self.sessionType]);
}

-(NSString *)cancelString{
    
    NSString *str;
    
    switch ([TMContractUtil sharedUtil].contractType) {
        case TMContractType_Normal:
        case TMContractType_Other:{
            str = [NSString stringWithFormat:@"%@ %@ 預計返還%@堂",[NSDate dateWithTimestamp:self.startTime].stringFormat6,[NSString stringWithSessionType:self.sessionType],self.usePoints];
            break;
        }

        case TMContractType_Unlimit:
        case TMContractType_Unlimit_1on1:
        case TMContractType_PowerSession:
        case TMContractType_PowerSession_1on1:
            if(_sessionType == TMNClassSessionType_1on1){
                str = [NSString stringWithFormat:@"%@ %@ 預計返還%@堂",[NSDate dateWithTimestamp:self.startTime].stringFormat6,[NSString stringWithSessionType:self.sessionType],self.usePoints];
            }else{
                str = [NSString stringWithFormat:@"%@ %@",[NSDate dateWithTimestamp:self.startTime].stringFormat6,[NSString stringWithSessionType:self.sessionType]];
            }

            break;
        default:
            str = @"";
            break;
    }
    
    return str;
}

-(NSString *)fullString{
    return [NSString stringWithFormat:@"%@ %@",[NSDate dateWithTimestamp:self.startTime].stringFormat6,[NSString stringWithSessionType:self.sessionType]];
}

static inline NSString *NSStringCCHashFunction(unsigned char *(function)(const void *data, CC_LONG len, unsigned char *md), CC_LONG digestLength, NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[digestLength];
    
    function(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:digestLength * 2];
    
    for (int i = 0; i < digestLength; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end

@implementation Classdetail

@end


@implementation TMPlanDummyLesson

@end