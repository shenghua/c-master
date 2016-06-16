//
//  MyProtocol.m
//  WebViewSample
//
//  Created by ledka on 15/12/18.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VAWebViewURLProtocol.h"

@implementation VAWebViewURLProtocol

+ (BOOL) canInitWithRequest:(NSURLRequest *)req{
    if ([req.URL.scheme caseInsensitiveCompare:@"vipabc"] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest*) canonicalRequestForRequest:(NSURLRequest *)req{
    return req;
}

- (void) startLoading{
    
    NSLog(@"%@", self.request.URL);
    NSString *urlString = [NSString stringWithFormat:@"%@", self.request.URL];
    NSString *fileName = [[urlString stringByReplacingOccurrencesOfString:@"vipabc://" withString:@""] stringByReplacingOccurrencesOfString:@".png" withString:@""];
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                        MIMEType:@"image/png"
                                           expectedContentLength:-1
                                                textEncodingName:nil];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void) stopLoading{
    NSLog(@"stopLoading");
}

@end
