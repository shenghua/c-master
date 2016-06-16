//
//  UrlUtility.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/20.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlUtility : NSObject
+ (NSString *)getParamValueWithKey:(NSString *)key fromUrl:(NSString *)url;
@end
