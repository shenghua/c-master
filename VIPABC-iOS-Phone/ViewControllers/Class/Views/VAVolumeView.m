//
//  VAVolumeView.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/25.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAVolumeView.h"
#import "VATool.h"

@interface VAVolumeView ()

@property (nonatomic, strong) UITableView *volumeTableView;

@end

@implementation VAVolumeView

@synthesize volumeTableView, volumeArray, currentUserName;

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    self.backgroundColor = [UIColor clearColor];
    
    if (!self.volumeArray)
        self.volumeArray = [NSArray array];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.7;
    [self addSubview:coverView];
    
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(self);
        make.left.equalTo(self.left);
        make.top.equalTo(self.top);
    }];
    
    self.volumeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    volumeTableView.backgroundColor = [UIColor clearColor];
    volumeTableView.showsVerticalScrollIndicator = NO;
    volumeTableView.delegate = self;
    volumeTableView.dataSource = self;
    volumeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:volumeTableView];
    
    [volumeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(310));
        make.height.equalTo(@(self.bounds.size.height - 150));
        make.top.equalTo(self).offset(80);
        make.centerX.equalTo(self);
    }];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.contentMode = UIViewContentModeScaleAspectFit;
    [closeButton setImage:[UIImage imageNamed:@"SessionRoomClose"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"SessionRoomClose"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(30));
        make.width.equalTo(@(30));
        make.top.equalTo(self).offset(18);
        make.right.equalTo(self).offset(-18);
    }];
    
    [volumeTableView reloadData];
}

#pragma mark - Button Events
- (void)removeView
{
    [self removeFromSuperview];
}

- (void)updateUserVolume:(UISlider *)sender {
    
    NSString *userName = volumeArray[sender.tag];
    if (sender.value == 0)
        sender.minimumValueImage = [UIImage imageNamed:@"SessionRoomVolumeMute"];
    else
        sender.minimumValueImage = [UIImage imageNamed:@"SessionRoomVolume"];
    
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
    
    if (sender.value == 0)
        sender.minimumValueImage = [UIImage imageNamed:@"SessionRoomVolumeMute"];
    else
        sender.minimumValueImage = [UIImage imageNamed:@"SessionRoomVolume"];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return volumeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SlideCellIdentity = @"SlideCellIdentity";
    
    NSString *userName = [volumeArray objectAtIndex:indexPath.section];
    NSString *userShortName = [[userName componentsSeparatedByString:@" "] objectAtIndex:0];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SlideCellIdentity];
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.borderColor = [UIColor clearColor].CGColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *firstLetterLabel = [VATool getLabelWithTextString:userShortName.length > 0 ? [[userShortName substringToIndex:1] uppercaseString] : @"" fontSize:16 textColor:[UIColor whiteColor] sapce:0 bold:YES];
    firstLetterLabel.backgroundColor = RGBCOLOR(76, 105, 151, 1);
    firstLetterLabel.layer.cornerRadius = 15;
    firstLetterLabel.layer.masksToBounds = YES;
    [cell addSubview:firstLetterLabel];
    
    [firstLetterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
        make.left.equalTo(@(5));
        make.top.equalTo(@(5));
    }];
    
    UILabel *userNameLabel = [VATool getLabelWithTextString:userShortName fontSize:15 textColor:[UIColor whiteColor] sapce:0 bold:NO];
    [cell addSubview:userNameLabel];
    
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLetterLabel.right).offset(8);
        make.centerY.equalTo(firstLetterLabel);
    }];
    
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumTrackTintColor = RGBCOLOR(228, 91, 82, 1);
    slider.maximumTrackTintColor = [UIColor whiteColor];
    slider.minimumValueImage = [UIImage imageNamed:@"SessionRoomVolume"];
    
//    UIImage *thumbImage = [self generateImageWithImageSize:CGRectMake(0, 0, 15, 15) color:[UIColor whiteColor]];
//    thumbImage = [self circleImage:thumbImage withParam:1.0];
//    
    [slider setThumbImage:[UIImage imageNamed:@"SessionRoomMemberVolumeSlider"] forState:UIControlStateNormal];
    
    if (!self.isLobbySession && indexPath.section == 0) { // Current User
        slider.value = self.session.getMicrophoneMute? 0: [self.session getMicrophoneGain];
        slider.enabled = self.session.getMicrophoneMute? NO: YES;
        [slider addTarget:self action:@selector(updateMicrophoneVolume:) forControlEvents:UIControlEventValueChanged];
        
    } else {
        slider.tag = indexPath.section;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            float f = [self.session getUserVolumeFactor:userName];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (slider.tag == indexPath.section) {
                    [UIView animateWithDuration:.2 animations:^{
                        slider.hidden = NO;
                        [slider setValue:f animated:NO];
                    }];
                }
            });
        });
        
        [slider addTarget:self action:@selector(updateUserVolume:) forControlEvents:UIControlEventValueChanged];
    }
    
    [cell addSubview:slider];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(170));
        make.height.equalTo(@(30));
        make.right.equalTo(cell).offset(-5);
        make.centerY.equalTo(firstLetterLabel);
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    
    return footerView;
}

#pragma mark - Util
// 根据颜色生成图片
- (UIImage *)generateImageWithImageSize:(CGRect)rect color:(UIColor *)color
{
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

//圆形的图片
- (UIImage*)circleImage:(UIImage*)image withParam:(CGFloat)inset {
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context,0); //边框线
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}


@end
