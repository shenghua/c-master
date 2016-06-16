//
//  DeviceUtility.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/24.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "DeviceUtility.h"
#include <sys/sysctl.h>

@implementation DeviceUtility
+ (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *)getHwMachine
{
    return [self getSysInfoByName:"hw.machine"];
}

+ (NSString *)platformFamilyName
{
    NSString *hwMachine = [self getHwMachine];
    if ([hwMachine hasPrefix:@"iPhone"]) return @"iPhone";
    if ([hwMachine hasPrefix:@"iPod"]) return @"iPod";
    if ([hwMachine hasPrefix:@"iPad"]) return @"iPad";
    if ([hwMachine hasPrefix:@"AppleTV"]) return @"AppleTV";
    
    return @"UnknownPlatformFamily";
}

+ (UIDevicePlatformFamily)platformFamily
{
    NSString *hwMachine = [self getHwMachine];
    if ([hwMachine hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([hwMachine hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([hwMachine hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([hwMachine hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    
    return UIDeviceFamilyUnknown;
}

+ (NSString *)platformName
{
    switch ([self platform])
    {
        case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4SiPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5iPhone: return IPHONE_5_NAMESTRING;
        case UIDevice5CiPhone: return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice6PlusiPhone: return IPHONE_6PLUS_NAMESTRING;
        case UIDevice6SiPhone: return IPHONE_6S_NAMESTRING;
        case UIDevice6SPlusiPhone: return IPHONE_6SPLUS_NAMESTRING;
        case UIDeviceUnknowniPhone: return IPHONE_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDevice6GiPod: return IPOD_6G_NAMESTRING;
        case UIDeviceUnknowniPod: return IPOD_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2iPad : return IPAD_2_NAMESTRING;
        case UIDevice3GiPad : return IPAD_3G_NAMESTRING;
        case UIDevice4GiPad : return IPAD_4G_NAMESTRING;
        case UIDeviceiPadAir : return IPAD_AIR_NAMESTRING;
        case UIDeviceiPadAir2 : return IPAD_AIR2_NAMESTRING;
        case UIDeviceiPadPro : return IPAD_PRO_NAMESTRING;
        case UIDevice1GiPadMini : return IPAD_MINI_1G_NAMESTRING;
        case UIDevice2GiPadMini : return IPAD_MINI_2G_NAMESTRING;
        case UIDevice3GiPadMini : return IPAD_MINI_3G_NAMESTRING;
        case UIDevice4GiPadMini : return IPAD_MINI_4G_NAMESTRING;
        case UIDeviceUnknowniPad : return IPAD_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3 : return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4 : return APPLETV_4G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleWatch1 : return APPLEWATCH_1_NAMESTRING;
        case UIDeviceUnknownAppleWatch: return APPLEWATCH_UNKNOWN_NAMESTRING;
            
        case UIDeviceSimulator: return SIMULATOR_NAMESTRING;
        case UIDeviceSimulatoriPhone: return SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceSimulatoriPad: return SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV: return SIMULATOR_APPLETV_NAMESTRING;
            
        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

+ (UIDevicePlatform)platform
{
    NSString *hwMachine = [self getHwMachine];
    
    // The ever mysterious iFPGA
    if ([hwMachine isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([hwMachine isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([hwMachine isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([hwMachine hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([hwMachine hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([hwMachine hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
    if ([hwMachine isEqualToString:@"iPhone5,1"] ||
        [hwMachine isEqualToString:@"iPhone5,2"])    return UIDevice5iPhone;
    if ([hwMachine isEqualToString:@"iPhone5,3"] ||
        [hwMachine isEqualToString:@"iPhone5,4"])    return UIDevice5CiPhone;
    if ([hwMachine isEqualToString:@"iPhone6,1"] ||
        [hwMachine isEqualToString:@"iPhone6,2"])    return UIDevice5SiPhone;
    if ([hwMachine isEqualToString:@"iPhone7,1"])    return UIDevice6PlusiPhone;
    if ([hwMachine isEqualToString:@"iPhone7,2"])    return UIDevice6iPhone;
    if ([hwMachine isEqualToString:@"iPhone8,1"])    return UIDevice6SiPhone;
    if ([hwMachine isEqualToString:@"iPhone8,2"])    return UIDevice6SPlusiPhone;
    
    // iPod
    if ([hwMachine hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([hwMachine hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([hwMachine hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([hwMachine hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([hwMachine hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    if ([hwMachine hasPrefix:@"iPod7"])              return UIDevice6GiPod;
    
    // iPad
    if ([hwMachine hasPrefix:@"iPad1"])              return UIDevice1GiPad;
    if ([hwMachine isEqualToString:@"iPad2,1"] ||
        [hwMachine isEqualToString:@"iPad2,2"] ||
        [hwMachine isEqualToString:@"iPad2,3"] ||
        [hwMachine isEqualToString:@"iPad2,4"])      return UIDevice2iPad;
    if ([hwMachine isEqualToString:@"iPad2,5"] ||
        [hwMachine isEqualToString:@"iPad2,6"] ||
        [hwMachine isEqualToString:@"iPad2,7"])      return UIDevice1GiPadMini;
    if ([hwMachine isEqualToString:@"iPad3,1"] ||
        [hwMachine isEqualToString:@"iPad3,2"] ||
        [hwMachine isEqualToString:@"iPad3,3"])      return UIDevice3GiPad;
    if ([hwMachine isEqualToString:@"iPad3,4"] ||
        [hwMachine isEqualToString:@"iPad3,5"] ||
        [hwMachine isEqualToString:@"iPad3,6"])      return UIDevice4GiPad;
    if ([hwMachine isEqualToString:@"iPad4,1"] ||
        [hwMachine isEqualToString:@"iPad4,2"] ||
        [hwMachine isEqualToString:@"iPad4,3"])      return UIDeviceiPadAir;
    if ([hwMachine isEqualToString:@"iPad4,4"] ||
        [hwMachine isEqualToString:@"iPad4,5"] ||
        [hwMachine isEqualToString:@"iPad4,6"])      return UIDevice2GiPadMini;
    if ([hwMachine isEqualToString:@"iPad4,7"] ||
        [hwMachine isEqualToString:@"iPad4,8"] ||
        [hwMachine isEqualToString:@"iPad4,9"])      return UIDevice3GiPadMini;
    if ([hwMachine isEqualToString:@"iPad5,1"] ||
        [hwMachine isEqualToString:@"iPad5,2"])      return UIDevice4GiPadMini;
    if ([hwMachine isEqualToString:@"iPad5,3"] ||
        [hwMachine isEqualToString:@"iPad5,4"])      return UIDeviceiPadAir2;
    if ([hwMachine isEqualToString:@"iPad6,7"] ||
        [hwMachine isEqualToString:@"iPad6,8"])      return UIDeviceiPadPro;
    
    // Apple TV
    if ([hwMachine hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    if ([hwMachine hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
    if ([hwMachine hasPrefix:@"AppleTV5"])           return UIDeviceAppleTV4;
    
    // Apple Watch
    if ([hwMachine hasPrefix:@"Watch1"])             return UIDeviceAppleWatch1;
    
    if ([hwMachine hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([hwMachine hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([hwMachine hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([hwMachine hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    if ([hwMachine hasPrefix:@"Watch"])              return UIDeviceUnknownAppleWatch;
    
    // Simulator thanks Jordan Breeding
    if ([hwMachine hasSuffix:@"86"] || [hwMachine isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

// Return screenSize according to statusBarOrientation
// For the OS below iOS 8, [[UIScreen mainScreen] bounds] always returns portrait bounds
// But for the iOS 8, [[UIScreen mainScreen] bounds] returns bounds according to the statusBarOrientation
+ (CGSize)screenSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    NSLog(@"screenSize.width = %f, screenSize.height = %f", screenSize.width, screenSize.height);
    
    if ((NSFoundationVersionNumber <= 1047.25) && // NSFoundationVersionNumber_iOS_7_1 = 1047.25
        UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    
    return screenSize;
}

+ (CGRect)mainScreenPortraitBounds
{
//    NSLog(@"NSFoundationVersionNumber = %f", NSFoundationVersionNumber);
    if (NSFoundationVersionNumber > 1047.25) {   // NSFoundationVersionNumber_iOS_7_1 = 1047.25
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                return [[UIScreen mainScreen] bounds];
            
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                return CGRectMake(0,
                                  0,
                                  [[UIScreen mainScreen] bounds].size.height,
                                  [[UIScreen mainScreen] bounds].size.width);
            default:
                return [[UIScreen mainScreen] bounds];
        }

    }
    
    return [[UIScreen mainScreen] bounds];
}

+ (CGFloat)screenScale
{
    CGFloat scale;
    
    SEL selector = NSSelectorFromString(@"nativeScale");    // available on iOS 8 and later
    if (![[UIScreen mainScreen] respondsToSelector:selector])
        selector = NSSelectorFromString(@"scale");
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [[[UIScreen mainScreen] class] instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIScreen mainScreen]];
    [invocation invoke];
    [invocation getReturnValue:&scale];
    
    return scale;
}

@end
