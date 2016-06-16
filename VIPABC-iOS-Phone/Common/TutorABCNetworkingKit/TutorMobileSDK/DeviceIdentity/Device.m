//
//  Device.m
//  Pods
//
//  Created by TingYao Hsu on 2015/12/30.
//
//

#import "Device.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>

static NSString * const ERROR_DOMAIN = @"com.tutorabc.TutorMobileSDK.error";
static NSString * const USER_DEFAULT_SUIT = @"TutorMobileSDK";
static NSString * const USER_DEFAULT_DATA_KEY = @"data";
static NSString * const USER_DEFAULT_DEVICEID_KEY = @"deviceId";
static NSString * const USER_DEFAULT_IDFA_KEY = @"idfa";
static NSString * const USER_DEFAULT_IDFV_KEY = @"idfv";

#if !DEBUG
static NSString const * SERVER_HOST = @"mobapi.vipabc.com";
static NSUInteger const SERVER_PORT = 80;
static NSString const * SERVER_SCHEME = @"http";
#else
static NSString * const SERVER_HOST = @"192.168.23.109";
static NSUInteger const SERVER_PORT = 8018;
static NSString * const SERVER_SCHEME = @"http";
#endif
static NSString * const SERVER_NEW_ID_PATH = @"/mobcommon/webapi/device/1/newId";
static NSString * const SERVER_TOUCH_ID_PATH = @"/mobcommon/webapi/device/1/touchId";
static NSString const * SERVER_JSON_ERR_KEY = @"status";
static NSString const * SERVER_JSON_DEVICEID_KEY = @"deviceId";


@interface Device ()
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSNumber *port;
@end

@implementation Device

/**
 Error Code of JSON response
 
 - Unknown:          Unknown error
 - UnexpectedResult: Unexpeted result from JSON, might missing some required element
 - TypeError:        Type Error
 - MalformedData:    The data format is not fulfil
 */
typedef NS_ENUM(NSInteger, DeviceRegisterError) {
    DeviceRegisterErrorUnknown          = 10100,
    DeviceRegisterErrorUnexpectedResult,
    DeviceRegisterErrorTypeError,
    DeviceRegisterErrorMalformedData,
};


+ (instancetype)sharedDevice {
    static Device *_sharedDevice = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedDevice = [self sharedDeviceWithHost:SERVER_HOST];
    });
    return _sharedDevice;
}

+ (instancetype)sharedDeviceWithHost:(NSString *)host {
    return [[self alloc] initWithHost:host port:@(SERVER_PORT) scheme:SERVER_SCHEME];
}

+ (instancetype)sharedDeviceWithHost:(NSString *)host port:(NSNumber *)port scheme:(NSString *)scheme {
    return [[self alloc] initWithHost:host port:port scheme:scheme];
}

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port scheme:(NSString *)scheme {
    self = [super init];
    
    if (self) {
        self.scheme = scheme;
        self.host = host;
        self.port = port;
    }
    
    return self;
}

- (void)registerWithBrandId:(NSString *)brandId completion:(void (^)(id data, NSError *err))completionHandler {
    
    // Collect device info
    NSString *idfv = UIDevice.currentDevice.identifierForVendor.UUIDString;
    NSString *idfa = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
    NSString *modifierId = self.deviceModel;
    
    // Check device from storage
    
    if (self.deviceId) {
        NSLog(@"Update Device ID");
        [self newIdWithDeviceId:self.deviceId imei:@"" mac:@"" idfv:idfv adid:@"" idfa:idfa brandId:brandId modifierId:modifierId completion:^(id data, NSError *err) {
            
            NSString *newId = data[@"deviceId"];
            if (newId.length) {
                self.deviceId = newId;
            }
            if (completionHandler) completionHandler(data, err);
        }];
        
    } else {
        NSLog(@"Generate New Device ID");
        // If no device registered, call newId
        [self newIdWithDeviceId:self.deviceId imei:@"" mac:@"" idfv:idfv adid:@"" idfa:idfa brandId:brandId modifierId:modifierId completion:^(id data, NSError *err) {
            NSString *newId = data[@"deviceId"];
            if (newId.length) {
                self.deviceId = newId;
            }
            if (completionHandler) completionHandler(data, err);
        }];
    }
}

#pragma mark - public methods
- (void)setDeviceId:(NSString *)newDeviceId {
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULT_SUIT];
    [userDefaults setValue:newDeviceId forKey:USER_DEFAULT_DEVICEID_KEY];
    [userDefaults synchronize];
//    KeychainStorage.saveData([USER_DEFAULT_DEVICEID_KEY: value!], forUserAccount: USER_DEFAULT_SUIT, inService: USER_DEFAULT_SUIT)
}

- (NSString *)deviceId {
    /// TODO: get Devcie ID by storage option
    
    // Read config
    // Check storage type, NSUserDefault | File | Keychain | Clipboard | None
    
    // Clipboard
    //        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    //        pasteboard.string = @"paste me somewhere";
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULT_SUIT];
//    let keychainStorage = KeychainStorage.loadDataForUserAccount(USER_DEFAULT_SUIT, inService: USER_DEFAULT_SUIT)
    
    if ([userDefaults stringForKey:USER_DEFAULT_DEVICEID_KEY].length) {
        
        NSString *deviceId = [userDefaults stringForKey:USER_DEFAULT_DEVICEID_KEY];
        NSLog(@"Retrieve DeviceID from User Defaults: %@", deviceId);
        return deviceId;
        
    }
//    else if let deviceId: String = keychainStorage.0?.objectForKey(USER_DEFAULT_DEVICEID_KEY) as? String {
//        print("Retrieve DeviceID from Keychain \(deviceId)")
//        return deviceId
//    }
    return nil;
}

#pragma mark - private methods

- (NSString *)idfa {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULT_SUIT];
    return [userDefaults stringForKey:USER_DEFAULT_IDFA_KEY];
}

- (void)setIdfa:(NSString *)idfa {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULT_SUIT];
    [userDefaults setValue:idfa forKey:USER_DEFAULT_IDFA_KEY];
    [userDefaults synchronize];
}

- (NSString *)idfv {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULT_SUIT];
    return [userDefaults stringForKey:USER_DEFAULT_IDFV_KEY];
}

- (void)setIdfv:(NSString *)idfv {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:USER_DEFAULT_SUIT];
    [userDefaults setValue:idfv forKey:USER_DEFAULT_IDFV_KEY];
    [userDefaults synchronize];
}

- (NSString *)deviceModel {
    return @"iOS";
}

- (void)touchIdWithDeviceId:(NSString *)deviceId
                       imei:(NSString *)imei
                        mac:(NSString *)mac
                       idfv:(NSString *)idfv
                       adid:(NSString *)adid
                       idfa:(NSString *)idfa
                    brandId:(NSString *)brandId
                 modifierId:(NSString *)modifierId
                 completion:(void (^)(id data, NSError *err))completionHandler {
    
    //
}

- (void)newIdWithDeviceId:(NSString *)deviceId
                     imei:(NSString *)imei
                      mac:(NSString *)mac
                     idfv:(NSString *)idfv
                     adid:(NSString *)adid
                     idfa:(NSString *)idfa
                  brandId:(NSString *)brandId
               modifierId:(NSString *)modifierId
               completion:(void (^)(id data, NSError *err))completionHandler {
    
//    if ([idfa isEqualToString:self.idfa] && [idfv isEqualToString:self.idfv]) {
//        NSLog(@"Skip touch since idfa and idfv is not changed.");
//        if (completionHandler) completionHandler(@{USER_DEFAULT_DEVICEID_KEY: deviceId}, nil);
//        return;
//        
//    } else {
        self.idfa = idfa;
        self.idfv = idfv;
//    }
    
//    NSLog(@"deviceId: %@", deviceId);
    NSLog(@"imei: %@", imei);
    NSLog(@"mac: %@", mac);
    NSLog(@"idfv: %@", idfv);
    NSLog(@"adid: %@", adid);
    NSLog(@"idfa: %@", idfa);
    NSLog(@"brandId: %@", brandId);
    NSLog(@"modifierId: %@", modifierId);
    
    NSURLSession *session = NSURLSession.sharedSession;
    
    NSURLComponents *urlComponent = [[NSURLComponents alloc] init];
    urlComponent.scheme = self.scheme;
    urlComponent.host = self.host;
    urlComponent.port = self.port;
    urlComponent.path = SERVER_NEW_ID_PATH;
    
    urlComponent.query = [@[[NSString stringWithFormat:@"imei=%@", imei],
                            [NSString stringWithFormat:@"mac=%@", mac],
                            [NSString stringWithFormat:@"idfv=%@", idfv],
                            [NSString stringWithFormat:@"adid=%@", adid],
                            [NSString stringWithFormat:@"idfa=%@", idfa],
                            [NSString stringWithFormat:@"brandId=%@", brandId],
                            [NSString stringWithFormat:@"modifierId=%@", modifierId],]
                          componentsJoinedByString:@"&"];
    
    NSLog(@"Url: %@", urlComponent.URL);
    
    [[session dataTaskWithURL:urlComponent.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"API error: %@", error);
            if (completionHandler) completionHandler(nil, error);
        } else {
            NSLog(@"HTTP Status Code: %@", response);
            
            NSError *jsonError;
            if (completionHandler) completionHandler([self parseData:data error:&jsonError], jsonError);
        }
    }] resume];
}

- (NSDictionary *)parseData:(NSData *)data error:(NSError * __autoreleasing *)error {
    
    // 10000 : Unknown
    // 10001 : Missing Param input (Invalid input argument)
    // 10002 : Wrong Param Type (Type Error exception)
    
    // 10100 : Unknown (output)
    // 10101 : Missing Param (Unexpected result)
    // 10102 : Wrong Param Type (Type Error)
    // 10103 : Malformed data
    
    NSError *err;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    // Parsing JSON to Dictionary
    if (err && error) {
        
        *error = err;
        
    } else {
        // Check device ID
        NSDictionary *data = json[USER_DEFAULT_DATA_KEY];
        NSString *key = [data objectForKey:USER_DEFAULT_DEVICEID_KEY];
        NSDictionary *serverError = json[SERVER_JSON_ERR_KEY];
        if (key.length == 32) {
            
            return data;
            
        } else if (serverError) {
            
            // TODO: error with
            *error = [NSError errorWithDomain:ERROR_DOMAIN code:DeviceRegisterErrorUnexpectedResult userInfo:@{NSLocalizedDescriptionKey: @"Unexpected result"}];
            
        } else if (error) {
            
            if (json[SERVER_JSON_DEVICEID_KEY] == nil) {
                
                *error = [NSError errorWithDomain:ERROR_DOMAIN code:DeviceRegisterErrorUnexpectedResult userInfo:@{NSLocalizedDescriptionKey: @"Unexpected result"}];
                
            } else if (![json[USER_DEFAULT_DEVICEID_KEY] isMemberOfClass:NSString.class]) {
                
                *error = [NSError errorWithDomain:ERROR_DOMAIN code:DeviceRegisterErrorTypeError userInfo:@{NSLocalizedDescriptionKey: @"Type Error"}];
                
            } else {
                
                *error = [NSError errorWithDomain:ERROR_DOMAIN code:DeviceRegisterErrorMalformedData userInfo:@{NSLocalizedDescriptionKey: @"Data format is invalid"}];
            }
        }
    }
    return nil;
}

@end
