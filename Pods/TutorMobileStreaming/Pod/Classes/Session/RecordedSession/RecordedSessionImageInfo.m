//
//  RecordedSessionImageInfo.m
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/16.
//
//

#import "RecordedSessionImageInfo.h"

@implementation RecordedSessionImageInfo

- (instancetype)initWithName:(NSString *)name width:(int)width height:(int)height {
    if (self = [super init]) {
        _name = [name copy];
        _width = width;
        _height = height;
    }
    return self;
}

@end
