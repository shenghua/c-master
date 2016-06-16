//
//  ChatView.m
//  TutorMobile
//
//  Created by Sendoh Chen_陳勇宇 on 2015/8/24.
//  Copyright (c) 2015年 TutorABC. All rights reserved.
//

#import "ChatView.h"
#import "ChatCell.h"
#import "SessionChatMessage.h"

static NSString *CellIdentifier = @"CellIdentifier";

@interface ChatView()
@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) NSMutableArray    *chatsArray;
@end

@implementation ChatView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _chatsArray = [NSMutableArray new];
        
        [self _setupTableView:frame];
    }
    return self;
}

- (void)_setupTableView:(CGRect)frame {
    CGRect tableViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    _tableView.allowsSelection = NO;
    _tableView.scrollEnabled = YES;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.userInteractionEnabled = YES;
    _tableView.bounces = YES;
    
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // This will remove extra separators from tableview
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_tableView registerClass:[ChatCell class] forCellReuseIdentifier:CellIdentifier];
    [self addSubview:_tableView];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chatsArray count];
}

- (ChatCell *)_createChatCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.userTimeLabel.text = [NSString stringWithFormat:@"%@ %@", [(SessionChatMessage *)(_chatsArray[indexPath.row]) userName], [(SessionChatMessage *)(_chatsArray[indexPath.row]) time]];
    cell.messageLabel.text = [(SessionChatMessage *)(_chatsArray[indexPath.row]) message];
    cell.priority = [(SessionChatMessage *)(_chatsArray[indexPath.row]) priority];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self _createChatCell:tableView indexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = [self _createChatCell:tableView indexPath:indexPath];

    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell layoutIfNeeded];
    
    return cell.contentView.bounds.size.height;
}

#pragma mark - Public methods
- (void)addChats:(NSArray *)chats {
    if (chats && [chats count]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(_chatsArray) {
                int origianlChatsCount = (int)[_chatsArray count];
                int finalChatsCount = origianlChatsCount + (int)[chats count];
                [_chatsArray addObjectsFromArray:chats];
                
                NSMutableArray *indexPathArary = [NSMutableArray new];
                for (int i = origianlChatsCount; i < finalChatsCount; i++)
                    [indexPathArary addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:indexPathArary
                                  withRowAnimation:UITableViewRowAnimationFade];
                [_tableView endUpdates];
                
                // Scroll to the bottom if at the bottom
                if(_tableView.contentOffset.y >= ((int)_tableView.contentSize.height - (int)_tableView.frame.size.height)) {
                    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForRow:finalChatsCount - 1 inSection:0];
                    [_tableView scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }
        });
    }
}

- (void)removeAllChats {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(_chatsArray) {
            [_chatsArray removeAllObjects];
            [_tableView  reloadData];
        }
    });
}
@end
