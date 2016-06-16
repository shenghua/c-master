//
//  HttpRequestUtility.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/11/18.
//
//

#import "HttpRequestUtility.h"

@implementation HttpRequestUtility

+ (void)sendAsyncHttpRequest:(NSString *)queryStr urlStr:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[queryStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable taskData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }];
    [dataTask resume];
}

+ (NSData *)sendSyncHttpRequest:(NSString *)queryStr urlStr:(NSString *)urlStr {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData *data = nil;
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[queryStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable taskData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        data = taskData;
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return data;
}

@end
