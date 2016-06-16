//
//  PopoverMenuButtonCell.h
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/9/1.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopoverMenuButtonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageText;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *middleButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *leftButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *rightButton;

@end
