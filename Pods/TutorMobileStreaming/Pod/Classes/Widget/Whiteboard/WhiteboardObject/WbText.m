//
//  WbText.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/9/22.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "WbText.h"
#import "TutorLog.h"

#define kInsetX 2.0
#define kInsetY 2.0
#define kDefaultWidth 250.0
#define kDefaultHeight 60.0
#define kServerMinWidth 45.0
#define kServerMinHeight 20.0

@interface WbText()
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int objId;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int color;
@property (nonatomic, strong) NSMutableString *text;
@property (nonatomic, strong) NSString *font;
@property (nonatomic, assign) int fontSize;
@property (nonatomic, assign) BOOL bold;
@property (nonatomic, assign) BOOL italic;
@property (nonatomic, assign) BOOL underline;

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSDictionary *textAttr;
@property (nonatomic, weak) WbText *weakSelf;
@end

@implementation WbText

+ (NSArray *)fontSizes
{
    static NSArray *_fontSizes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fontSizes = @[@(8), @(9), @(10), @(11), @(12), @(14), @(16), @(18), @(20), @(21), @(22), @(25), @(28), @(35), @(48)];
//      _fontSizes = @[@(8), @(10), @(12), @(14), @(16), @(18), @(20), @(22), @(24), @(26), @(28), @(32), @(36), @(48), @(72)]; // Web
    });
    return _fontSizes;
}

- (instancetype)initWithWo:(SessionWhiteboardObject *)wo {
    if (self = [super initWithWo:wo]) {
        _weakSelf = self;
        [self update:wo];
    }
    return self;
}

- (void)update:(SessionWhiteboardObject *)wo {
    [wo.properties enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        switch ([(NSNumber *)key intValue]) {
            case 0:
                _x = ([(NSNumber *)object intValue] + kInsetX) * self.scale;
                break;
                
            case 1:
                _y = ([(NSNumber *)object intValue] + kInsetY) * self.scale;
                break;
                
            case 2:
                _objId = [(NSNumber *)object intValue];
                break;
                
            case 3:
                _width = [(NSNumber *)object intValue];
                if (_width < kServerMinWidth)
                    _width = kDefaultWidth;
                _width *= self.scale;
                break;
                
            case 4:
                _height = [(NSNumber *)object intValue];
                if (_height < kServerMinHeight)
                    _height = kDefaultWidth;
                _height *= self.scale;
                break;
                
            case 5:
                _color = [(NSNumber *)object intValue];
                break;
                
            case 6:
                if (!_text) _text = [NSMutableString new];
                [_text setString:[(NSString *)object copy]];
                break;
                
            case 7:
                _font = [(NSString *)object copy];
                break;
                
            case 8:
                _fontSize = [(NSNumber *)object intValue];
                break;
                
            case 9:
                _bold = [(NSNumber *)object boolValue];
                break;
                
            case 10:
                _italic = [(NSNumber *)object boolValue];
                break;
                
            case 11:
                _underline = [(NSNumber *)object boolValue];
                break;
            default:
                break;
        }
    }];
    
    [self _setupTextFont];
    [self _setupTextColor];
    [self _setupTextAttr];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        _weakSelf.frame = CGRectMake(_x, _y, _width, _height);
        [_weakSelf setNeedsDisplay];
    });
}

// http://iosfonts.com/
- (void)_setupTextFont {
    NSArray *fineSizes = [[self class] fontSizes];
    NSString *fontName = @"Helvetica";
    
    if (_bold || _italic) {
        fontName = [fontName stringByAppendingString:@"-"];
        if (_bold)
            fontName = [fontName stringByAppendingString:@"Bold"];
        if (_italic)
            fontName = [fontName stringByAppendingString:@"Oblique"];
    }
    
    _textFont = [UIFont fontWithName:fontName size:[fineSizes[_fontSize] floatValue] * self.scale];
}

- (void)_setupTextColor {
    NSArray *rgb = [WbObject getRGB:_color];
    _textColor = [UIColor colorWithRed:[rgb[0] floatValue]
                                 green:[rgb[1] floatValue]
                                  blue:[rgb[2] floatValue]
                                 alpha:1.0];
}

- (void)_setupTextAttr {
    _textAttr = @{NSFontAttributeName:_textFont,
              NSUnderlineStyleAttributeName:[NSNumber numberWithBool:_underline],
              NSForegroundColorAttributeName:_textColor};
//    [_text setAttributes:_textAttr range:NSMakeRange(0, _text.length)];
}

- (void)drawRect:(CGRect)rect {
    NSString *text = [_weakSelf.text copy];
    NSDictionary *textAttr = [[NSDictionary alloc] initWithDictionary:_weakSelf.textAttr];

    if (text && textAttr)
        [text drawInRect:rect withAttributes:textAttr];
}

@end