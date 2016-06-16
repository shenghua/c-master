//
//  ChatCell.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/24.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "ChatCell.h"

#define kLabelHorizontalInsets      5.0f
#define kLabelVerticalInsets        5.0f
#define kUserTimeLabelH             20.0f

@implementation ChatCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.userTimeLabel = [[UILabel alloc] init];
        [self.userTimeLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.userTimeLabel setNumberOfLines:1];
        self.userTimeLabel.adjustsFontSizeToFitWidth = YES;
        [self.userTimeLabel setTextAlignment:NSTextAlignmentLeft];
        [self.userTimeLabel setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8]];
        self.userTimeLabel.backgroundColor = [UIColor clearColor];
        
        self.messageLabel = [[UILabel alloc] init];
        [self.messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.messageLabel setNumberOfLines:0];
        [self.messageLabel setTextAlignment:NSTextAlignmentLeft];
        [self.messageLabel setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8]];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.userTimeLabel];
        [self.contentView addSubview:self.messageLabel];
        
        [self _updateFonts];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.contentView.frame.size.width - 2 * kLabelHorizontalInsets;
    self.userTimeLabel.frame = CGRectMake(kLabelHorizontalInsets, kLabelVerticalInsets, width, kUserTimeLabelH);
    
    CGRect lblTextSize = [self.messageLabel.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName:self.messageLabel.font}
                                                              context:nil];
    self.messageLabel.frame = CGRectMake(kLabelHorizontalInsets, kLabelVerticalInsets + self.userTimeLabel.frame.size.height, width, lblTextSize.size.height);
    
    self.contentView.bounds = CGRectMake(0,
                                         0,
                                         self.contentView.frame.size.width,
                                         2 * kLabelVerticalInsets + self.userTimeLabel.bounds.size.height + self.messageLabel.bounds.size.height);
}

- (void)_updateFonts {
    self.userTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (void)setPriority:(SessionChatMessagePriority)priority {
    _priority = priority;
    
    if (_priority == SessionChatMessagePriority_High)
        [self.userTimeLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]];
    else
        [self.userTimeLabel setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8]];
    
    if (_priority == SessionChatMessagePriority_High)
        [self.messageLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]];
    else
        [self.messageLabel setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8]];
}

@end
