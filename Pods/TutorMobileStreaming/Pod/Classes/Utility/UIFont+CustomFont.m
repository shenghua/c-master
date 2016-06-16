//
//  UIFont+CustomFont.m
//  Pods
//
//  Created by TingYao Hsu on 2015/11/30.
//
//

#import "UIFont+CustomFont.h"
#import <CoreText/CoreText.h>

static NSString * const kBundle = @"Fonts.bundle";

@implementation UIFont (CustomFont)

+ (UIFont *)montserratFontOfSize:(CGFloat)size {
    NSString *fontName = @"Montserrat-Regular";
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (!font) {
        [[self class] dynamicallyLoadFontNamed:fontName];
        font = [UIFont fontWithName:fontName size:size];
        
        // safe fallback
        if (!font) font = [UIFont systemFontOfSize:size];
    }
    
    return font;
}

+ (void)dynamicallyLoadFontNamed:(NSString *)name {
    NSString *resourceName = [NSString stringWithFormat:@"%@/%@", kBundle, name];
    NSURL *url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"otf"];
    NSData *fontData = [NSData dataWithContentsOfURL:url];
    if (fontData) {
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            NSLog(@"Failed to load font: %@", errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}
@end
