//
//  TutormeetBroker.m
//  Pods
//
//  Created by TingYao Hsu on 2015/10/30.
//
//

#import "TutormeetBroker.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

NSString * const _Nonnull kTutorMeetConfigUrl = @"http://www.tutormeet.com/tutormeet/config/tutormeet_init.txt";
NSString * const _Nonnull kLogDoApiHostDefault = @"cn.tutormeet.com";
NSString * const _Nonnull kLogDoApiPathAddSessionLog = @"tutormeetweb/log.do";
NSString * const _Nonnull kLoginDoApiUrl = @"http://www.tutormeet.com/tutormeetweb/login.do";
NSString * const _Nonnull kRecordDoApiUrl = @"http://www.tutormeet.com/tutormeetweb/record.do";
NSString * const _Nonnull kUserDoApiUrl = @"http://www.tutormeet.com/tutormeetweb/user.do";
NSString * const _Nonnull kSetSessionInfoUrl = @"http://www.tutorabc.com/tutorpad/app/SetSessionInfo.ashx";
NSString * const _Nonnull kRecordInfoApiUrl = @"http://192.168.23.109:8018/mobcommon/webapi/freesession/1/getDetail?fileName=_recording_session919_859zVWCMHK_2015093023919&clientSn=1234&brandId=1";
NSString * const _Nonnull kTutormeetBrokerUserDefaults = @"TutormeetBroker";
NSString * const _Nonnull kLoginDoApiUrlKey = @"LoginDoApiUrl";

@implementation TutormeetBroker
+ (void)fetchTutotmeetConfig:(void (^)(NSDictionary *data))completionHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLComponents *url = [[NSURLComponents alloc] initWithString:kTutorMeetConfigUrl];
    
    NSLog(@"tutormmet init url: %@", url);
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"tutormeet init: %@", json);
        
        NSString *loginDoApiUrl = [NSString stringWithFormat:@"http://%@/tutormeetweb/login.do", json[@"WEB_AUTH_HOST"]];
        NSLog(@"Login.do API URL: %@", loginDoApiUrl);
        
        [[NSUserDefaults standardUserDefaults] setObject:loginDoApiUrl forKey:kLoginDoApiUrlKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) completionHandler(json);
        });
        
    }];
    [dataTask resume];
}

+ (void)retriveSessionInfoWithSessionSn:(NSString * _Nonnull)sessionSn
                          sessionRoomId:(NSString * _Nonnull)sessionRoomId
                     sessionRoomRandStr:(NSString * _Nonnull)sessionRoomRandStr
                              classType:(NSString * _Nonnull)classType
                             compStatus:(NSString * _Nonnull)compStatus
                                 userSn:(NSString * _Nonnull)userSn
                             completion:(void (^)(NSDictionary *data))completionHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kLoginDoApiUrlKey]? [[NSUserDefaults standardUserDefaults] stringForKey:kLoginDoApiUrlKey]: kLoginDoApiUrl;
    NSURLComponents *url = [[NSURLComponents alloc] initWithString:baseUrl];
    
    url.query = [@[[NSString stringWithFormat:@"action=%@", @"tutormeetLogin"],
                   [NSString stringWithFormat:@"class_type=%@", classType],
                   [NSString stringWithFormat:@"comp_status=%@", compStatus],
                   [NSString stringWithFormat:@"session_room_id=%@", sessionRoomId],
                   [NSString stringWithFormat:@"session_room_rand_str=%@", sessionRoomRandStr],
                   [NSString stringWithFormat:@"session_sn=%@", sessionSn],
                   [NSString stringWithFormat:@"user_sn=%@", userSn]]
                 componentsJoinedByString:@"&"];
    
    NSLog(@"login url: %@", url);
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"login.do: %@", json);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) completionHandler(json);
        });
        
    }];
    [dataTask resume];
}

+ (void)retriveRecordInfoWithFileName:(NSString *)fileName
                           compStatus:(NSString *)compStatus
                               userSn:(NSString *)userSn
                           completion:(void (^)(NSDictionary *data))completionHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLComponents *url = [[NSURLComponents alloc] initWithString:kRecordDoApiUrl];
    
    url.query = [@[[NSString stringWithFormat:@"action=%@", @"getRecoding"],
                   [NSString stringWithFormat:@"fileName=%@", fileName],
                   [NSString stringWithFormat:@"comp_status=%@", compStatus],
                   [NSString stringWithFormat:@"clientSn=%@", userSn]]
                 componentsJoinedByString:@"&"];
    
    NSLog(@"record url: %@", url);
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"record.do: %@", json);
        
        if (completionHandler) completionHandler(json);
        
    }];
    [dataTask resume];
}

+ (void)presentClassWithSessionSn:(NSString *)sessionSn
                         userType:(NSString *)userType
                           userSn:(NSString *)userSn
                       compStatus:(NSString *)compStatus
                       completion:(void (^)(NSData * data,
                                            NSURLResponse * response,
                                            NSError * error))callback {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLComponents *url = [[NSURLComponents alloc] initWithString:kUserDoApiUrl];
    
    url.query = [@[[NSString stringWithFormat:@"action=%@", @"loginStatus"],
                   [NSString stringWithFormat:@"sessionSn=%@", sessionSn],
                   [NSString stringWithFormat:@"userType=%@", userType],
                   [NSString stringWithFormat:@"userSn=%@", userSn],
                   [NSString stringWithFormat:@"comp_status=%@", compStatus],
                   [NSString stringWithFormat:@"status=%@", @"1"],
                   [NSString stringWithFormat:@"ip=%@", [self getIPAddress]],]
                 componentsJoinedByString:@"&"];
    
    
    NSLog(@"user.do url: %@", url);
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error.localizedDescription);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"user.do: %@", json);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) callback(data, response, error);
        });
        
    }];
    [dataTask resume];
}

+ (void)presentClassWithSessionSn:(NSString *)sessionSn
                          account:(NSString *)account
                         password:(NSString *)password
                          website:(NSString *)website
                             mode:(NSString *)mode
                       completion:(void (^)(NSData * data,
                                            NSURLResponse * response,
                                            NSError * error))callback {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLComponents *url = [[NSURLComponents alloc] initWithString:kSetSessionInfoUrl];
    
    url.query = [@[[NSString stringWithFormat:@"account=%@", account],
                   [NSString stringWithFormat:@"password=%@", password],
                   [NSString stringWithFormat:@"website=%@", website],
                   [NSString stringWithFormat:@"mode=%@", mode],
                   [NSString stringWithFormat:@"session_sn=%@", sessionSn],]
                 componentsJoinedByString:@"&"];
    
    
    NSLog(@"SetSessionInfo url: %@", url);
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error.localizedDescription);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"SetSessionInfo: %@", json);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) callback(data, response, error);
        });
        
    }];
    [dataTask resume];
}

+ (void)addSessionLogWithSessionSn:(NSString *)sessionSn
                            userSn:(NSString *)userSn
                          userType:(NSString *)userType
                            server:(NSString *)server
                        compStatus:(NSString *)compStatus
                        completion:(void (^)(NSData * data,
                                             NSURLResponse * response,
                                             NSError * error))callback {
    NSURLComponents *url = [[NSURLComponents alloc] initWithString:[NSString stringWithFormat:@"http://%@/%@", kLogDoApiHostDefault, kLogDoApiPathAddSessionLog]];
    
    NSString *srcIp = [self getIPAddress];
    NSString *dstIp = server;
    NSString *deviceInfo = [NSString stringWithFormat:@"%@ %@", UIDevice.currentDevice.systemName, UIDevice.currentDevice.systemVersion];
    NSString *content = [NSString stringWithFormat:@"rtmp %@->%@ Mobile:%@", srcIp, dstIp, deviceInfo];
    
    
    url.query = [@[[NSString stringWithFormat:@"action=%@", @"addSessionLog"],
                   [NSString stringWithFormat:@"compStatus=%@", compStatus],
                   [NSString stringWithFormat:@"content=%@", content],
                   [NSString stringWithFormat:@"event=%@", @"Login"],
                   [NSString stringWithFormat:@"logType=%@", @"1"],
                   [NSString stringWithFormat:@"sessionSn=%@", sessionSn],
                   [NSString stringWithFormat:@"userSn=%@", userSn],
                   [NSString stringWithFormat:@"userType=%@", userType],
                   ]
                 componentsJoinedByString:@"&"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (callback) callback(data, response, error);
        
    }];
    
    [dataTask resume];
}

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}
@end

