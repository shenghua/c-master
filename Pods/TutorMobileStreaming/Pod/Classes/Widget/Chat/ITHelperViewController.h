//
//  ITHelperViewController.h
//  Pods
//
//  Created by TingYao Hsu on 2015/12/7.
//
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>

@class LiveSession;

@interface ITHelperViewController : JSQMessagesViewController
@property (nonatomic, weak) LiveSession *session;
@property (nonatomic, weak) NSMutableArray *messages;
@end
