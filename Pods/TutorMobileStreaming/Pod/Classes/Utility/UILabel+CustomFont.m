//
//  UILabel+CustomFont.m
//  Pods
//
//  Created by TingYao Hsu on 2015/11/30.
//
//

#import "UILabel+CustomFont.h"
#import "UIFont+CustomFont.h"

@implementation UILabel (CustomFont)
- (void)setSubstituteFontName:(NSString *)name UI_APPEARANCE_SELECTOR {
    if ([@"Montserrat-Regular" isEqualToString:name]) {
        self.font = [UIFont montserratFontOfSize:self.font.pointSize];
    } else {
        self.font = [UIFont fontWithName:name size:self.font.pointSize];
    }
}
@end
