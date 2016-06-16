//
//  RecordedSessionImageInfo.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/16.
//
//

#import <Foundation/Foundation.h>

@interface RecordedSessionImageInfo : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;

- (instancetype)initWithName:(NSString *)name width:(int)width height:(int)height;
@end
