//
//  TutorMobileStreaming.m
//  Pods
//
//  Created by TingYao Hsu on 2015/11/24.
//
//

#import "TutorMobileStreaming.h"
#import <TutorMobileStreaming/TutormeetBroker.h>

@implementation TutorMobileStreaming
+ (void)init {
    [TutormeetBroker fetchTutotmeetConfig:nil];
}
@end
