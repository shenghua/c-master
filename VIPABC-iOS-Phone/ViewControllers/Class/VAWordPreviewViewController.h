//
//  VAWordPreviewViewController.h
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/2/25.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VABaseViewController.h"
#import "TMClassInfo.h"

@interface VAWordPreviewViewController : VABaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TMClassInfo *classinfo;

@end
