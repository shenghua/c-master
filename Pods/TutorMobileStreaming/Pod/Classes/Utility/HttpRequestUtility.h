//
//  HttpRequestUtility.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/11/18.
//
//

#import <Foundation/Foundation.h>

@interface HttpRequestUtility : NSObject
+ (void)sendAsyncHttpRequest:(NSString *)queryStr urlStr:(NSString *)urlStr;
+ (NSData *)sendSyncHttpRequest:(NSString *)queryStr urlStr:(NSString *)urlStr;
@end
