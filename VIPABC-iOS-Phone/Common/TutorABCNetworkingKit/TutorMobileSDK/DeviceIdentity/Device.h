//
//  Device.h
//  Pods
//
//  Created by TingYao Hsu on 2015/12/30.
//
//

#import <Foundation/Foundation.h>

@interface Device : NSObject
@property (nonatomic, strong, readonly) NSString *deviceId;

+ (instancetype)sharedDevice;
+ (instancetype)sharedDeviceWithHost:(NSString *)host;
+ (instancetype)sharedDeviceWithHost:(NSString *)host port:(NSString *)port scheme:(NSString *)scheme;
- (instancetype)initWithHost:(NSString *)host port:(NSString *)port scheme:(NSString *)scheme;
- (void)registerWithBrandId:(NSString *)brandId completion:(void (^)(id data, NSError *err))completionHandler;
@end
