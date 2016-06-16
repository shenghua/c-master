//
//  UIViewController+SessionRoom.h
//  Pods
//
//  Created by TingYao Hsu on 2015/11/12.
//
//

#import <UIKit/UIKit.h>
#import "RecordedSession.h"

@class RecordedSessionType1ViewController;

@interface UIViewController (SessionRoom)
// This method will call login.do with data, and present view controller from root view controller.
- (void)showLiveSessionType1WithClassInfo:(NSDictionary * _Nonnull)classInfo
                               completion:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

- (void)showLiveSessionType2WithClassInfo:(NSDictionary * _Nonnull)classInfo
                               completion:(void (^ _Nullable)(NSError * _Nullable error))completionHandler;

- (void)showRecordSessionType1WithClassInfo:(NSDictionary * _Nonnull)classInfo
                                 completion:(void (^ _Nullable)(NSError * _Nullable error, RecordedSessionType1ViewController * _Nullable vc))completionHandler;

- (void)showRecordSessionType1WithClassInfo:(NSDictionary * _Nonnull)classInfo
                                   delegate:(id<RecordedSessionDelegate> _Nullable)delegate
                                 completion:(void (^ _Nullable)(NSError * _Nullable error, RecordedSessionType1ViewController * _Nullable vc))completionHandler;

- (void)showFreeSessionType1WithClassInfo:(NSDictionary * _Nonnull)classInfo
                               completion:(void (^ _Nullable)(NSError * _Nullable error, RecordedSessionType1ViewController * _Nullable vc))completionHandler;
@end
