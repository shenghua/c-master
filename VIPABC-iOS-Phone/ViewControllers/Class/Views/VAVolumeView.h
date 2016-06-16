//
//  VAVolumeView.h
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/25.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveSession.h"

@protocol VAVolumeViewDelegate <NSObject>

- (void)didUpdateMicrophoneVolume:(UISlider *)slider;

@end

@interface VAVolumeView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) LiveSession *session;
@property (nonatomic, assign) BOOL isLobbySession;
@property (nonatomic, copy) NSString *currentUserName;
@property (nonatomic, strong) NSArray *volumeArray;

@property (nonatomic, weak) id<VAVolumeViewDelegate> delegate;

@end
