//
//  VAClassPreparationViewController.h
//  VIPABC4Phone
//
//  Created by ledka on 16/1/9.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VABaseViewController.h"
#import "TMClassInfo.h"
#import "TMConsultant.h"

@interface VAClassPreparationViewController : VABaseViewController

@property (nonatomic, strong) TMClassInfo *classInfo;
@property (nonatomic, strong) TMConsultant *consultant;

@end
