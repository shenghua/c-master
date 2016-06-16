//
//  RecordedSessionType1ViewController.h
//  Pods
//
//  Created by TingYao Hsu on 2015/11/3.
//
//

#import <UIKit/UIKit.h>
#import "RecordedSession.h"

extern NSString *const _Nonnull UIRecordSessionType1WillCloseNotification;

@interface RecordedSessionType1ViewController : UIViewController

@property (nonnull, nonatomic, strong) NSString *sessionSn;
@property (nonnull, nonatomic, strong) NSString *server;
@property (nonnull, nonatomic, strong) NSString *classStartMin;
@property (nullable, nonatomic, weak) id<RecordedSessionDelegate> delegate;

- (nullable instancetype)initWithServer:(NSString * _Nonnull)server
                              sessionSn:(NSString * _Nonnull)sessionSn
                          classStartMin:(NSString * _Nullable)classStartMin;
- (void)setPlaybackCallback:(void(^ _Nonnull)(RecordedSessionType1ViewController * _Nonnull viewController))callback withInterval:(NSTimeInterval)time;
@end
