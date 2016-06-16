//
//  SessionWhiteboardObject.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/20.
//
//

#import <Foundation/Foundation.h>
#import <librtmp/rtmp.h>

@interface SessionWhiteboardObject : NSObject
@property (nonatomic, assign) int objId;
@property (nonatomic, assign) WhiteboardShape shape;
@property (nonatomic, strong) NSMutableDictionary *properties;
@end
