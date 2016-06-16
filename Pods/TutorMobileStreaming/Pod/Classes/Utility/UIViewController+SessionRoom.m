//
//  UIViewController+SessionRoom.m
//  Pods
//
//  Created by TingYao Hsu on 2015/11/12.
//
//

#import "UIViewController+SessionRoom.h"
#import "TutormeetBroker.h"
#import "LiveSessionType1ViewController.h"
#import "LiveSessionType2ViewController.h"
#import "RecordedSessionType1ViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <AlertView/AlertView.h>

@implementation UIViewController (SessionRoom)

- (void)showLiveSessionType1WithClassInfo:(NSDictionary *)classInfo
                               completion:(void (^)(NSError *error))completionHandler {
    
    __weak id weakSelf = self;
    // Check data
    if (!classInfo) {
        NSLog(@"Class info should not be nil");
        NSError *err = [[NSError alloc] initWithDomain:NSArgumentDomain
                                                  code:100002
                                              userInfo:@{NSLocalizedDescriptionKey: @"Class info should not be nil"}];
        if (completionHandler) completionHandler(err);
        return;
    }
    
    __block NSNumber *isDemo = classInfo[@"isDemo"];
    __block NSNumber *isAllow1toN = classInfo[@"isAllow1toN"];
    
    // Prepare completion callback
    void (^startSession)(NSDictionary *) = ^void (NSDictionary *data) {
        
       if (!data || !data[@"ename"]) {
            // TODO: show error for empty data
            NSLog(@"Error, data is invalid");
            NSError *err = [[NSError alloc] initWithDomain:NSArgumentDomain
                                                      code:100002
                                                  userInfo:@{NSLocalizedDescriptionKey: @"data is invalid"}];
            if (completionHandler) completionHandler(err);
            return;
            
        } else {
            // TODO: Skip 1-to-6 session
            if (!isAllow1toN.boolValue && [data[@"lobbySession"] isEqualToString:@"N"]) {
                [SVProgressHUD dismiss];
                AlertView *alert = [AlertView showInfoWithTitle:@"" text:@"小班制功能即將開放，敬請期待"];
                [alert.rightButton setTitle:@"OK" forState:UIControlStateNormal];
                alert.rightButtonWidthConstraint.constant = 255.f;
                alert.leftButtonWidthConstraint.constant = 0.f;
                if (completionHandler) completionHandler(nil);
                return;
            }
            // TODO ---
        }
        
        LiveSessionType1ViewController *viewController = [[LiveSessionType1ViewController alloc] initWithClassInfo:data isDemo:isDemo.boolValue];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:nav animated:YES completion:^{
                if (completionHandler) completionHandler(nil);
            }];
        });
    };
    
    NSString *classType = classInfo[@"classType"];
    NSString *compStatus = classInfo[@"compStatus"];
    NSString *sessionRoomId = classInfo[@"sessionRoomId"];
    NSString *sessionRoomRandStr = classInfo[@"randStr"];
    NSString *sessionSn = classInfo[@"sessionSn"];
    NSString *userSn = classInfo[@"clientSn"];
    
    [TutormeetBroker retriveSessionInfoWithSessionSn:sessionSn
                                       sessionRoomId:sessionRoomId
                                  sessionRoomRandStr:sessionRoomRandStr
                                           classType:classType
                                          compStatus:compStatus
                                              userSn:userSn
                                          completion:startSession];

}

- (void)showLiveSessionType2WithClassInfo:(NSDictionary * _Nonnull)classInfo
                               completion:(void (^)(NSError *error))completionHandler {
    
//    NSAssert(classInfo, @"Class info should not be nil");
    if (!classInfo) {
        NSLog(@"Class info should not be nil");
        NSError *err = [[NSError alloc] initWithDomain:NSArgumentDomain
                                                  code:100002
                                              userInfo:@{NSLocalizedDescriptionKey: @"Class info should not be nil"}];
        if (completionHandler) completionHandler(err);
        return;
    }
    
    __weak id weakSelf = self;
    NSString *sessionSn = classInfo[@"SessionSn"];
    NSString *sessionRoomId = classInfo[@"SessionRoomId"];
    NSString *sessionRoomRandStr = classInfo[@"RoomRandString"];
    NSString *classType = classInfo[@"ClassType"];
    NSString *compStatus = classInfo[@"CompStatus"];
    NSString *userSn = classInfo[@"ClientSn"];
    
    void (^startSession)(NSDictionary *) = ^void (NSDictionary *data) {
        
        if (!data || !data[@"ename"]) {
            NSLog(@"Error, data is invalid");
            NSError *err = [[NSError alloc] initWithDomain:NSArgumentDomain
                                                      code:100002
                                                  userInfo:@{NSLocalizedDescriptionKey: @"data is invalid"}];
            if (completionHandler) completionHandler(err);
            return;
        }
        
        LiveSessionType2ViewController *sessionRoom = [[LiveSessionType2ViewController alloc] init];
        sessionRoom.classInfo = data;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:sessionRoom animated:YES completion:^{
                if (completionHandler) completionHandler(nil);
            }];
        });
    };
    
    // Get session room info
    [TutormeetBroker retriveSessionInfoWithSessionSn:sessionSn
                                       sessionRoomId:sessionRoomId
                                  sessionRoomRandStr:sessionRoomRandStr
                                           classType:classType
                                          compStatus:compStatus
                                              userSn:userSn
                                          completion:startSession];
}

- (void)showRecordSessionType1WithClassInfo:(NSDictionary *)classInfo
                                 completion:(void (^)(NSError *error, RecordedSessionType1ViewController *vc))completionHandler {
    
    [self showRecordSessionType1WithClassInfo:classInfo delegate:nil completion:completionHandler];
}

- (void)showRecordSessionType1WithClassInfo:(NSDictionary *)classInfo
                                   delegate:(id<RecordedSessionDelegate>)delegate
                                 completion:(void (^)(NSError *error, RecordedSessionType1ViewController *vc))completionHandler {
    __weak id weakSelf = self;
    
    if (!classInfo) {
        NSLog(@"Class info should not be nil");
        NSError *err = [[NSError alloc] initWithDomain:NSArgumentDomain
                                                  code:100002
                                              userInfo:@{NSLocalizedDescriptionKey: @"Class info should not be nil"}];
        if (completionHandler) completionHandler(err, nil);
        return;
    }
    
    void (^startSession)(NSDictionary *) = ^void (NSDictionary *data) {
        
        if (!data || !data[@"serverIP"]) {
            NSLog(@"Error, data is invalid");
            NSError *err = [[NSError alloc] initWithDomain:NSArgumentDomain
                                                      code:100002
                                                  userInfo:@{NSLocalizedDescriptionKey: @"data is invalid"}];
            if (completionHandler) completionHandler(err, nil);
            return;
        }
        
        NSString *server = data[@"serverIP"];
        NSString *sessionSn = [[[data objectForKey:@"videoName"] componentsSeparatedByString:@"_"] lastObject];
        NSString *classStartMin = classInfo[@"classStartMin"];
        // NSDictionary *classInfo = @{@"server":@"210.5.31.86", @"sessionSn": @"2015101523755"};
        RecordedSessionType1ViewController *viewController = [[RecordedSessionType1ViewController alloc] initWithServer:server sessionSn:sessionSn classStartMin:classStartMin];
        viewController.delegate = delegate;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:nav animated:YES completion:^{
                if (completionHandler) completionHandler(nil, viewController);
            }];
        });
        
    };
    
    NSString *fileName = classInfo[@"fileName"];
    NSString *compStatus = classInfo[@"compStatus"];
    NSString *userSn = classInfo[@"clientSn"];
    
    [TutormeetBroker retriveRecordInfoWithFileName:fileName
                                        compStatus:compStatus
                                            userSn:userSn
                                        completion:startSession];
}

- (void)showFreeSessionType1WithClassInfo:(NSDictionary *)classInfo
                               completion:(void (^)(NSError *error, RecordedSessionType1ViewController *vc))completionHandler {
    
    __weak id weakSelf = self;
    
    if (!classInfo || !classInfo[@"serverIP"]) {
        NSLog(@"Class info should not be nil");
        NSError *err = [[NSError alloc] initWithDomain:NSArgumentDomain
                                                  code:100002
                                              userInfo:@{NSLocalizedDescriptionKey: @"Class info should not be nil"}];
        if (completionHandler) completionHandler(err, nil);
        return;
    }
    
    NSString *server = classInfo[@"serverIP"];
    NSString *sessionSn = [[[classInfo objectForKey:@"videoName"] componentsSeparatedByString:@"_"] lastObject];
    NSString *classStartMin = classInfo[@"classStartMin"];
    // NSDictionary *classInfo = @{@"server":@"210.5.31.86", @"sessionSn": @"2015101523755"};
    RecordedSessionType1ViewController *viewController = [[RecordedSessionType1ViewController alloc] initWithServer:server sessionSn:sessionSn classStartMin:classStartMin];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf presentViewController:nav animated:YES completion:^{
            if (completionHandler) completionHandler(nil, viewController);
        }];
    });
    
}
@end
