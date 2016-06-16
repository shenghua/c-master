//
//  RecordedSession.h
//  Pods
//
//  Created by Sendoh Chen_陳勇宇 on 2015/10/15.
//
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "SessionChatMessage.h"
#import "RecordedWhiteboard.h"
#import "RecordedSessionDataParser.h"

@protocol RecordedSessionDelegate <NSObject>
- (void)onSessionStarted:(BOOL)success;
- (void)onSessionStopped;
- (void)onSessionDuration:(long long)duration;   // milliseconds
- (void)onPositionChanged:(long long)position;   // milliseconds

- (void)onUserIn:(NSString *)userName isPresenter:(BOOL)isPresenter;

- (void)onMessage:(NSArray<SessionChatMessage *> *)messages;
- (void)onClearAllMessages;                     // called after seeking
- (void)onWhiteboardPageChanged:(int)pageIdx;   // starting from 0
- (void)onWhiteboardTotalPages:(int)totalPages;

- (void)onVideoFps:(int)fps;
@end

@interface RecordedSession : NSObject <PlayerDelegate, WhiteboardDelegate, RecordedSessionDataParserDelegate>
@property (nonatomic, weak) id<RecordedSessionDelegate> delegate;
@property (nonatomic, strong) NSString *anchor;                     // Store the current anchor (coordinator or cohost), default is coordinator
@property (nonatomic, strong) NSString *shortUserName;

- (instancetype)initSession:(NSDictionary *)sessionInfo             // @"server", @"sessionSn", @"userName", @"classStartMin"
                   delegate:(id<RecordedSessionDelegate>)delegate
                  videoView:(UIView *)videoView
             whiteboardView:(UIView *)whiteboardView;
- (void)startSession:(long long)position;   // milliseconds, will seek to position after onSessionStarted if position > 0
- (void)stopSession;

- (void)seek:(long long)position;   // millisecond
- (void)pause;
- (void)resume;
@end
