//
//  TutormeetBroker.h
//  Pods
//
//  Created by TingYao Hsu on 2015/10/30.
//
//

#import <Foundation/Foundation.h>

extern NSString * const _Nonnull kLogDoApiHostDefault;
extern NSString * const _Nonnull kLogDoApiPathAddSessionLog;

@interface TutormeetBroker : NSObject

// Get tutormeet.init file for domain host mapping
+ (void)fetchTutotmeetConfig:(void (^ _Nullable)(NSDictionary * _Nullable data))completionHandler;

// Get login.do data
+ (void)retriveSessionInfoWithSessionSn:(NSString * _Nonnull)sessionSn
                          sessionRoomId:(NSString * _Nonnull)sessionRoomId
                     sessionRoomRandStr:(NSString * _Nonnull)sessionRoomRandStr
                              classType:(NSString * _Nonnull)classType
                             compStatus:(NSString * _Nonnull)compStatus
                                 userSn:(NSString * _Nonnull)userSn
                             completion:(void (^ _Nullable)(NSDictionary * _Nullable data))completionHandler;

// Get record.do data
+ (void)retriveRecordInfoWithFileName:(NSString * _Nonnull)fileName
                           compStatus:(NSString * _Nonnull)compStatus
                               userSn:(NSString * _Nonnull)userSn
                           completion:(void (^ _Nullable)(NSDictionary * _Nullable data))completionHandler;

// User.do for present class
+ (void)presentClassWithSessionSn:(NSString * _Nonnull)sessionSn
                         userType:(NSString * _Nonnull)userType
                           userSn:(NSString * _Nonnull)userSn
                       compStatus:(NSString * _Nonnull)compStatus
                       completion:(void (^ _Nonnull)(NSData * _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error))callback;

// SetSessionInfo for present class
+ (void)presentClassWithSessionSn:(NSString * _Nonnull)sessionSn
                          account:(NSString * _Nonnull)account
                         password:(NSString * _Nonnull)password
                          website:(NSString * _Nonnull)website
                             mode:(NSString * _Nonnull)mode
                       completion:(void (^ _Nonnull)(NSData * _Nonnull data,
                                                     NSURLResponse * _Nonnull response,
                                                     NSError * _Nullable error))callback;

// Make current user is presented to the class
+ (void)addSessionLogWithSessionSn:(NSString * _Nonnull)sessionSn
                            userSn:(NSString * _Nonnull)userSn
                          userType:(NSString * _Nonnull)userType
                            server:(NSString * _Nonnull)server
                        compStatus:(NSString * _Nonnull)compStatus
                        completion:(void (^ _Nullable)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) callback;
@end