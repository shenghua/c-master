//
//  TMResponse.h
//  TutorMobile
//
//  Created by Tony Tsai_蔡豐屹 on 9/21/15.
//  Copyright (c) 2015 TutorABC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMStatus;

@interface TMArrayResponse : NSObject

@property (nonatomic, strong) TMStatus *status;
@property (nonatomic, strong) NSArray *data;

@end

@interface TMDictResponse : NSObject

@property (nonatomic, strong) TMStatus *status;
@property (nonatomic, strong) NSDictionary *data;

@end


@interface TMStatus : NSObject

@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) NSInteger code;

@end

