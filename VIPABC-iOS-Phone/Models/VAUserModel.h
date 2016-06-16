//
//  VAUserModel.h
//  VIPABC4Phone
//
//  Created by ledka on 15/11/30.
//  Copyright © 2015年 vipabc. All rights reserved.
//

#import "VABaseModel.h"

@interface VAUserModel : VABaseModel

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *token;

@end
