//
//  RecordedSessionStream.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/20.
//
//

#import <Foundation/Foundation.h>

@interface RecordedSessionStream : NSObject
@property (nonatomic, assign) BOOL isPresenter;
@property (nonatomic, strong) NSString *publishName;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) long long startTime;
@property (nonatomic, strong) NSMutableArray *enterLeaveTimeList;
@end
