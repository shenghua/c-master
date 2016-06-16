//
//  UrlUtility.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/20.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "UrlUtility.h"

@implementation UrlUtility
+ (NSString *)getParamValueWithKey:(NSString *)k fromUrl:(NSString *)url {
    NSAssert(k && url, @"Invalid parameters");
    
    NSString *key = [k stringByAppendingString:@"="];
    NSRange range = [url rangeOfString:key];
    
    if (range.location != NSNotFound) {
        NSString *val = [url substringFromIndex:range.location + key.length];
        range = [val rangeOfString:@"&"];
        if (range.location != NSNotFound)
            val = [val substringToIndex:range.location];
        
        return val;
    }
    
    return nil;
}
@end
