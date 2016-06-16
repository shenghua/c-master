//
//  PopoverMenuSliderCell.m
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/9/1.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "PopoverMenuSliderCell.h"

@implementation PopoverMenuSliderCell

- (void)awakeFromNib {
    // Initialization code
    [self.slider setMinimumTrackImage:[UIImage imageNamed:@"sessionroom_bg_slider"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
