//
//  PopoverMenuViewController.m
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/9/1.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "PopoverMenuViewController.h"
#import "PopoverMenuSliderCell.h"
#import "PopoverMenuButtonCell.h"
//#import <AlertView/AlertView.h>
#import "LiveSession.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

NSUInteger const kPopoverMenuTypePlain = 0;
NSUInteger const kPopoverMenuTypeSlider = 1;
NSUInteger const kPopoverMenuTypeButton = 2;

NSUInteger const kPopoverCellHeightPlain = 44;
NSUInteger const kPopoverCellHeightSlider = 72;
NSUInteger const kPopoverCellHeightButton = 90;

NSUInteger const kPopoverMessageTargetConsultant = 0;
NSUInteger const kPopoverMessageTargetIT = 1;

@interface PopoverMenuViewController ()
@end

@implementation PopoverMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.menuTitle;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:20.f],
                                                                    NSForegroundColorAttributeName: UIColorFromRGB(0x404040)};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.menuType == kPopoverMenuTypeButton && !self.menu.count) return 1;
    return self.menu.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.menuType) {
            
        case kPopoverMenuTypeSlider:
            return kPopoverCellHeightSlider;
            break;
            
        case kPopoverMenuTypeButton:
            return kPopoverCellHeightButton;
            break;
            
        case kPopoverMenuTypePlain:
        default:
            return kPopoverCellHeightPlain;
            break;
    }
}

#pragma mark - UITableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    switch (self.menuType) {
            
        case kPopoverMenuTypeSlider: {
            PopoverMenuSliderCell *sliderCell = (PopoverMenuSliderCell *)[tableView dequeueReusableCellWithIdentifier:@"SliderCell"];
            NSString *userName = self.menu[indexPath.row];
            
            sliderCell.userNameText.text = [userName componentsSeparatedByString:@"~"].firstObject;
            
            if (!self.isLobbySession && indexPath.row == 0) { // Current User
                sliderCell.slider.minimumValueImage = [UIImage imageNamed:@"sessionroom_icon_mike_disable"];
                sliderCell.slider.maximumValueImage = [UIImage imageNamed:@"sessionroom_icon_mike_default"];
                
                sliderCell.slider.value = self.session.getMicrophoneMute? 0: [self.session getMicrophoneGain];
                sliderCell.slider.enabled = self.session.getMicrophoneMute? NO: YES;
                [sliderCell.slider addTarget:self action:@selector(updateMicrophoneVolume:) forControlEvents:UIControlEventValueChanged];
                
            } else {
                sliderCell.slider.tag = indexPath.row;
                sliderCell.slider.hidden = YES;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
                    float f = [self.session getUserVolumeFactor:userName];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (sliderCell.slider.tag == indexPath.row) {
                            [UIView animateWithDuration:.2 animations:^{
                                sliderCell.slider.hidden = NO;
                                [sliderCell.slider setValue:f animated:YES];
                            }];
                        }
                    });
                });
                
                [sliderCell.slider addTarget:self action:@selector(updateUserVolume:) forControlEvents:UIControlEventValueChanged];
            }
            
            cell = sliderCell;
            break;
        }
            
        case kPopoverMenuTypeButton: {
            if (self.menu.count == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"Placeholder"];
            } else {
                PopoverMenuButtonCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
                buttonCell.messageText.text = [NSString stringWithFormat: @"%@", self.menu[indexPath.row]];
                [buttonCell.leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [buttonCell.rightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [buttonCell.middleButton addTarget:self action:@selector(middleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                buttonCell.leftButton.tag = buttonCell.middleButton.tag = buttonCell.rightButton.tag = indexPath.row;
                cell = buttonCell;
            }
            break;
        }
            
        case kPopoverMenuTypePlain:
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"PlainCell"];
            cell.textLabel.text = self.menu[indexPath.row];
            cell.textLabel.enabled = self.menuEnabled;
            cell.selectionStyle = self.menuEnabled? UITableViewCellSelectionStyleDefault: UITableViewCellSelectionStyleNone;
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.menuType) {
        case kPopoverMenuTypePlain: {
            if (self.menuEnabled) {
                [self.delegate didSelectPlainStyleItem:indexPath
                                                sender:self.sender
                                           withMessage:self.menu[indexPath.row]];
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)updateUserVolume:(UISlider *)sender {

    NSString *userName = self.menu[sender.tag];
    [self.session setUserVolumeFactor:sender.value userName:userName];
}

- (void)updateMicrophoneVolume:(UISlider *)sender {
    if (sender.value < 0.05) { // Set to mute if it's very small
        
        [self.session setMicrophoneGain:0.f];
        [self.session setMicrophoneMute:YES];
        sender.alpha = .5f;
        sender.value = 0.f;
        
    } else {
        
        [self.session setMicrophoneMute:NO];
        [self.session setMicrophoneGain:sender.value];
        sender.alpha = 1.f;
    }
    
    if ([self.delegate respondsToSelector:@selector(didUpdateMicrophoneVolume:)]) {
        [self.delegate didUpdateMicrophoneVolume:sender];
    }
}

- (BOOL)isLobbySession {
    return [@"Y" isEqualToString:self.classInfo[@"lobbySession"]] || [@"true" isEqualToString:self.classInfo[@"lobbySession"]];
}

- (IBAction)leftButtonPressed:(UIButton *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    if ([self.delegate respondsToSelector:@selector(didSelectButtonStyleItem:sender:buttonIndex:)]) {
        [self.delegate didSelectButtonStyleItem:indexPath sender:sender buttonIndex:0];
    }
}

- (IBAction)middleButtonPressed:(UIButton *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    if ([self.delegate respondsToSelector:@selector(didSelectButtonStyleItem:sender:buttonIndex:)]) {
        [self.delegate didSelectButtonStyleItem:indexPath sender:sender buttonIndex:1];
    }
}

- (IBAction)rightButtonPressed:(UIButton *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    if ([self.delegate respondsToSelector:@selector(didSelectButtonStyleItem:sender:buttonIndex:)]) {
        [self.delegate didSelectButtonStyleItem:indexPath sender:sender buttonIndex:2];
    }
}
@end
