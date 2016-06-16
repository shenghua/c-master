//
//  PopoverMenuViewController.h
//  TutorMobile
//
//  Created by TingYao Hsu on 2015/9/1.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LiveSession;

extern NSUInteger const kPopoverMenuTypePlain;
extern NSUInteger const kPopoverMenuTypeSlider;
extern NSUInteger const kPopoverMenuTypeButton;

extern NSUInteger const kPopoverCellHeightPlain;
extern NSUInteger const kPopoverCellHeightSlider;
extern NSUInteger const kPopoverCellHeightButton;

extern NSUInteger const kPopoverMessageTargetConsultant;
extern NSUInteger const kPopoverMessageTargetIT;

@protocol PopoverMenuDelegate <NSObject>

@optional
- (void)didSelectPlainStyleItem:(NSIndexPath *)path
                         sender:(id)sender
                    withMessage:(NSString *)message;
- (void)didSelectButtonStyleItem:(NSIndexPath *)path
                          sender:(id)sender
                     buttonIndex:(int)buttonIndex;
- (void)didUpdateMicrophoneVolume:(UISlider *)slider;
@end

@interface PopoverMenuViewController : UITableViewController
@property (weak, nonatomic) id<PopoverMenuDelegate> delegate;
@property (weak, nonatomic) id sender;
@property (weak, nonatomic) LiveSession *session;
@property (weak, nonatomic) NSDictionary *classInfo;
@property (strong, nonatomic) NSArray *menu;
@property (strong, nonatomic) NSString *menuTitle;
@property (assign, nonatomic) NSUInteger menuType;
@property (assign, nonatomic) BOOL menuEnabled;
@end