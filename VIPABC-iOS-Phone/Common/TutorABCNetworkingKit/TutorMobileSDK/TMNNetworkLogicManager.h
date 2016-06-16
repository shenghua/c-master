//
//  TMNNetworkLogicManager.h
//  TutorMobileSDK
//
//  Created by Eddy Tsai_蔡佳翰 on 2015/12/31.
//  Copyright © 2015年 Eddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNNetworkLogicController.h"
//#import <TutorMobileSDK/TMNNetworkLogicController.h>

@interface TMNNetworkLogicManager : NSObject

+ (TMNNetworkLogicController *)sharedInstace;

@end
