//
//  RecordedSessionRoomViewController.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/15.
//
//

#import <Foundation/Foundation.h>
#import "RecordedSession.h"
#import "ChatView.h"

@interface RecordedSessionRoomViewController : UIViewController <RecordedSessionDelegate>
@property (nonatomic, strong) NSDictionary *sessionInfo; // @"server", @"sessionSn", @"userName", @"classStartMin", @"lobbySession"
@end
