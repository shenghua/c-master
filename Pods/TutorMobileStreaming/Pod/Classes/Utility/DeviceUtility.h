//
//  DeviceUtility.h
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/24.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// http://theiphonewiki.com/wiki/Models
// http://en.wikipedia.org/wiki/List_of_iOS_devices
#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"            // iPhone1,1
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"            // iPhone1,2
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS"           // iPhone2,1
#define IPHONE_4_NAMESTRING             @"iPhone 4"             // iPhone3,1 / iPhone3,2 / iPhone3,3
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"            // iPhone4,1
#define IPHONE_5_NAMESTRING             @"iPhone 5"             // iPhone5,1 / iPhone5,2
#define IPHONE_5C_NAMESTRING            @"iPhone 5C"            // iPhone5,3 / iPhone5,4
#define IPHONE_5S_NAMESTRING            @"iPhone 5S"            // iPhone6,1 / iPhone6,2
#define IPHONE_6_NAMESTRING             @"iPhone 6"             // iPhone7,2
#define IPHONE_6PLUS_NAMESTRING         @"iPhone 6 Plus"        // iPhone7,1
#define IPHONE_6S_NAMESTRING            @"iPhone 6S"            // iPhone8,1
#define IPHONE_6SPLUS_NAMESTRING        @"iPhone 6S Plus"       // iPhone8,2
#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1G_NAMESTRING              @"iPod touch 1G"        // iPod1,1
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"        // iPod2,1
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"        // iPod3,1
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"        // iPod4,1
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"        // iPod5,1
#define IPOD_6G_NAMESTRING              @"iPod touch 6G"        // iPod7,1
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"              // iPad1,1
#define IPAD_2_NAMESTRING               @"iPad 2"               // iPad2,1 / iPad2,2 / iPad2,3 / iPad2,4
#define IPAD_3G_NAMESTRING              @"iPad 3G"              // iPad3,1 / iPad3,2 / iPad3,3
#define IPAD_4G_NAMESTRING              @"iPad 4G"              // iPad3,4 / iPad3,5 / iPad3,6
#define IPAD_AIR_NAMESTRING             @"iPad Air"             // iPad4,1 / iPad4,2
#define IPAD_AIR2_NAMESTRING            @"iPad Air2"            // iPad5,3 / iPad5,4
#define IPAD_PRO_NAMESTRING             @"iPad Pro"             // iPad6,7 / iPad6,8
#define IPAD_MINI_1G_NAMESTRING         @"iPad Mini 1G"         // iPad2,5 / iPad2,6 / iPad2,7
#define IPAD_MINI_2G_NAMESTRING         @"iPad Mini 2G"         // iPad4,4 / iPad4,5
#define IPAD_MINI_3G_NAMESTRING         @"iPad Mini 3G"         // iPad4,7 / iPad4,8 / iPad4,9
#define IPAD_MINI_4G_NAMESTRING         @"iPad Mini 4G"         // iPad5,1 / iPad5,2
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define APPLEWATCH_1_NAMESTRING         @"Apple Watch"
#define APPLEWATCH_UNKNOWN_NAMESTRING   @"Unknown Apple Watch"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define SIMULATOR_NAMESTRING            @"iPhone Simulator"
#define SIMULATOR_IPHONE_NAMESTRING     @"iPhone Simulator"
#define SIMULATOR_IPAD_NAMESTRING       @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING    @"Apple TV Simulator" // :)

typedef enum {
    UIDeviceUnknown,
    
    UIDeviceSimulator,
    UIDeviceSimulatoriPhone,
    UIDeviceSimulatoriPad,
    UIDeviceSimulatorAppleTV,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4SiPhone,
    UIDevice5iPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    UIDevice6iPhone,
    UIDevice6PlusiPhone,
    UIDevice6SiPhone,
    UIDevice6SPlusiPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    UIDevice6GiPod,
    
    UIDevice1GiPad,
    UIDevice2iPad,
    UIDevice1GiPadMini,
    UIDevice3GiPad,
    UIDevice4GiPad,
    UIDeviceiPadAir,
    UIDeviceiPadAir2,
    UIDeviceiPadPro,
    UIDevice2GiPadMini,
    UIDevice3GiPadMini,
    UIDevice4GiPadMini,
    
    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    
    UIDeviceAppleWatch1,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV,
    UIDeviceUnknownAppleWatch,
    UIDeviceIFPGA,
    
} UIDevicePlatform;

typedef enum {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown,
    
} UIDevicePlatformFamily;

@interface DeviceUtility : NSObject
+ (NSString *)platformFamilyName;
+ (UIDevicePlatformFamily)platformFamily;
+ (NSString *)platformName;
+ (UIDevicePlatform)platform;
+ (CGSize)screenSize;
+ (CGRect)mainScreenPortraitBounds;
+ (CGFloat)screenScale;
@end
