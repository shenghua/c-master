//
//  ChatButton.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/26.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "ChatButton.h"

@implementation ChatButton

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor blackColor];
    }
    else {
        self.backgroundColor = [UIColor brownColor];
    }
}

@end
