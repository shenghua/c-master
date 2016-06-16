//
//  VAMessagesView.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/1/20.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAMessagesView.h"
#import "VATool.h"
#import "IQKeyboardManager.h"
#import "VAMessageFrame.h"
#import "VAMessageCell.h"

#define kMessagesTableVewWidth  iPhone6 ? 350.0 : 320.0

@interface VAMessagesView () <UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *cellHeights;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) NSArray *actionSheetTitles;
@property (nonatomic, strong) NSArray *commonLanguageArray;
@property (nonatomic, strong) NSMutableArray *colorArray;
@property (nonatomic, assign) BOOL scrollToBottom;

@property (nonatomic, strong) NSMutableArray *allMessagesFrame;
@property (nonatomic, copy) NSString *previousTime;

@end

@implementation VAMessagesView

@synthesize messagesTableView, messages, cellHeights, toolView, messageTextField, allMessagesFrame, previousTime;

- (instancetype)initWithMessageType:(ChatMessageType)chatMessageType
{
    self = [super init];
    if (!self) return nil;
    
    if (!messages)
        self.messages = [[NSMutableArray alloc] init];
    
    self.cellHeights = [[NSMutableArray alloc] init];
    self.scrollToBottom = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.chatMessageType = chatMessageType;
    
    if (self.chatMessageType == ChatMessageTypeIT) {
        self.actionSheetTitles = @[NSLocalizedString(@"There is communication noise", nil),
                                   NSLocalizedString(@"There is communication delay", nil),
                                   NSLocalizedString(@"Consultant is not in classroom", nil),
                                   NSLocalizedString(@"Consultant can't hear me", nil),
                                   NSLocalizedString(@"Can't hear consultant", nil),
                                   NSLocalizedString(@"Can't hear classmates", nil),
                                   NSLocalizedString(@"Consultant sounds very low", nil),
                                   NSLocalizedString(@"Can't see material", nil),
                                   NSLocalizedString(@"Ask IT to contact with me", nil),
                                   NSLocalizedString(@"Communication issue, please contact me later", nil),
                                   NSLocalizedString(@"Consultant issue, please contact me later", nil),
                                   NSLocalizedString(@"Material issue, please contact me later", nil),];
        
        self.commonLanguageArray = @[@"There is communication noise",
                                     @"There is communication delay",
                                     @"Consultant is not in classroom",
                                     @"Consultant can't hear me",
                                     @"Can't hear consultant",
                                     @"Can't hear classmates",
                                     @"Consultant sounds very low",
                                     @"Can't see material",
                                     @"Ask IT to contact with me",
                                     @"Communication issue, please contact me later",
                                     @"Consultant issue, please contact me later",
                                     @"Material issue, please contact me later"];
    }
    else {
        self.actionSheetTitles = @[NSLocalizedString(@"Too fast", nil),
                                   NSLocalizedString(@"Too slow", nil),
                                   NSLocalizedString(@"Don't read context only", nil),
                                   NSLocalizedString(@"Correct me ASAP", nil),
                                   NSLocalizedString(@"Assist to answer", nil),
                                   NSLocalizedString(@"More time to talk", nil),
                                   NSLocalizedString(@"Classmates talk too much", nil)];
        
        self.commonLanguageArray = @[@"Too fast",
                                     @"Too slow",
                                     @"Don't read context only",
                                     @"Correct me ASAP",
                                     @"Assist to answer",
                                     @"More time to talk",
                                     @"Classmates talk too much"];
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    self.allMessagesFrame = [NSMutableArray array];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    for (JSQMessage *message in messages) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSString *time = [dateFormatter stringFromDate:message.date];
        
        VAMessageFrame *messageFrame = [[VAMessageFrame alloc] init];
        NSString *senderDisplayNameToIT = [NSString stringWithFormat:@"%@ to IT", self.session.shortUserName];

        if ([message.senderDisplayName isEqualToString:self.session.shortUserName] || [message.senderDisplayName isEqualToString:senderDisplayNameToIT])
            messageFrame.messageType = MessageTypeMe;
        else
            messageFrame.messageType = MessageTypeOther;
        
        messageFrame.showTime = ![previousTime isEqualToString:time];
        
        messageFrame.message = message;
        
        previousTime = time;
        
        [allMessagesFrame addObject:messageFrame];
    }
    
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.7;
    [self addSubview:coverView];
    
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(self);
        make.left.equalTo(self.left);
        make.top.equalTo(self.top);
    }];
    
    self.messagesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    messagesTableView.backgroundColor = [UIColor clearColor];
    messagesTableView.showsVerticalScrollIndicator = NO;
    messagesTableView.delegate = self;
    messagesTableView.dataSource = self;
    messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:messagesTableView];
    
    self.toolView = [[UIView alloc] init];
    toolView.backgroundColor = [UIColor clearColor];
    toolView.hidden = NO;
    [self addSubview:toolView];
    
    [toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@(60));
        make.bottom.equalTo(self.bottom);
    }];
    
    [messagesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kMessagesTableVewWidth));
        make.top.equalTo(self.top).offset(20);
        make.bottom.equalTo(toolView.top).offset(-10);
        make.centerX.equalTo(coverView);
    }];
    
    UIView *toolCoverView = [[UIView alloc] init];
    toolCoverView.backgroundColor = [UIColor whiteColor];
    toolCoverView.alpha = 0.5;
    [toolView addSubview:toolCoverView];
    
    [toolCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(toolView);
        make.height.equalTo(toolView);
        make.left.equalTo(toolView.left);
        make.top.equalTo(toolView.top);
    }];
    
    self.messageTextField = [[UITextField alloc] init];
    messageTextField.placeholder = @"";
    messageTextField.backgroundColor = [UIColor whiteColor];
    messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    messageTextField.layer.cornerRadius = 7;
    messageTextField.returnKeyType = UIReturnKeySend;
    messageTextField.delegate = self;
    [toolView addSubview:messageTextField];
    
    [messageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(toolView).offset(-80);
        make.height.equalTo(@(40));
        make.left.equalTo(toolView.left).offset(15);
        make.top.equalTo(toolView).offset(10);
    }];
    
    UIButton *commonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commonButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [commonButton setTitle:@"常用" forState:UIControlStateNormal];
    commonButton.titleLabel.font = DEFAULT_FONT(14);
    commonButton.backgroundColor = [UIColor whiteColor];
    commonButton.layer.cornerRadius = 20;
    [commonButton addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:commonButton];
    
    [commonButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
        make.centerY.equalTo(messageTextField);
        make.right.equalTo(toolView).offset(-10);
    }];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.contentMode = UIViewContentModeScaleAspectFit;
    [closeButton setImage:[UIImage imageNamed:@"SessionRoomClose"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"SessionRoomClose"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(30));
        make.width.equalTo(@(30));
        make.top.equalTo(self).offset(18);
        make.right.equalTo(self).offset(-18);
    }];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [self refreshTableView];
    
    messagesTableView.contentSize = CGSizeMake(messagesTableView.frame.size.width, messagesTableView.frame.size.height - messagesTableView.frame.origin.y);
    [messagesTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

#pragma mark - Actions
- (void)hideKeyBoard
{
    [messageTextField resignFirstResponder];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [toolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottom);
    }];
    
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    CGRect kbFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [toolView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottom).offset(-kbFrame.size.height);
    }];
    
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
        
        if (self.messages.count > 0) {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.messages.count - 1];
            [messagesTableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showActionSheet
{
    [self hideKeyBoard];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取 消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    for (NSString *str in _actionSheetTitles) {
        [actionSheet addButtonWithTitle:str];
    }
    
    [actionSheet showInView:self];
}

- (void)removeView
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kMessageViewRemoveNotification object:nil];
    
    [self removeFromSuperview];
}

- (void)refreshTableView
{
    [messagesTableView reloadData];
    
    [messagesTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex====== %ld", (long)buttonIndex);
    
    if (buttonIndex != 0) {
        if (self.chatMessageType == ChatMessageTypeIT)
            [self.session sendHelpMessage:[_commonLanguageArray objectAtIndex:buttonIndex - 1] msgIdx:[NSNumber numberWithInteger:buttonIndex - 1]];
        else
            [self sendMessage:[_commonLanguageArray objectAtIndex:buttonIndex - 1]];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return allMessagesFrame.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *MessageCellIdentity = @"MessageCellIdentity";
    //
    ////    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentity];
    //
    //    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentity];
    //    cell.backgroundColor = [UIColor clearColor];
    //    cell.layer.borderColor = [UIColor clearColor].CGColor;
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //
    //    JSQMessage *chatMessage = [self.messages objectAtIndex:indexPath.section];
    //
    //    UIView *coverView = [[UIView alloc] init];
    //    coverView.backgroundColor = [UIColor whiteColor];
    //    coverView.alpha = 0.2;
    //    [cell addSubview:coverView];
    //
    //    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(cell);
    //        make.height.equalTo(cell);
    //        make.left.equalTo(cell.left);
    //        make.top.equalTo(cell.top);
    //    }];
    //
    //    UILabel *firstLetterLabel = [VATool getLabelWithTextString:[[chatMessage.senderDisplayName substringToIndex:1] uppercaseString] fontSize:16 textColor:[UIColor whiteColor] sapce:0 bold:YES];
    //    firstLetterLabel.backgroundColor = RGBCOLOR(76, 105, 151, 1);
    //    firstLetterLabel.layer.cornerRadius = 10;
    //    firstLetterLabel.layer.masksToBounds = YES;
    //    [cell addSubview:firstLetterLabel];
    //
    //    [firstLetterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(@(20));
    //        make.height.equalTo(@(20));
    //        make.left.equalTo(@(5));
    //        make.top.equalTo(@(5));
    //    }];
    //
    //    UILabel *userNameLabel = [VATool getLabelWithTextString:chatMessage.senderDisplayName fontSize:16 textColor:[UIColor whiteColor] sapce:0 bold:YES];
    //    [cell addSubview:userNameLabel];
    //
    //    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(firstLetterLabel.right).offset(5);
    //        make.top.equalTo(firstLetterLabel);
    //    }];
    //
    //    UILabel *messageLabel = [VATool getLabelWithTextString:chatMessage.text fontSize:18 textColor:[UIColor whiteColor] sapce:0 bold:YES];
    //    messageLabel.textAlignment = NSTextAlignmentLeft;
    //    [cell addSubview:messageLabel];
    //
    //    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(@(200));
    //        make.left.equalTo(userNameLabel);
    //        make.top.equalTo(userNameLabel.bottom).offset(10);
    //    }];
    //
    //    cell.layer.cornerRadius = 8;
    //    cell.layer.masksToBounds = YES;
    
    static NSString *CellIdentifier = @"MessageCellIdentity";
    VAMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.isConsultant = NO;
    
    if (cell == nil) {
        cell = [[VAMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    VAMessageFrame *messageFram = allMessagesFrame[indexPath.section];
    
    if ([[self.consultantName lowercaseString] hasPrefix:messageFram.message.senderDisplayName.lowercaseString])
        cell.isConsultant = YES;
    
    // 设置数据
    cell.messageFrame = messageFram;
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row && self.scrollToBottom){
        //end of loading
        dispatch_async(dispatch_get_main_queue(),^{
            self.scrollToBottom = NO;
            if (messagesTableView.contentSize.height > messagesTableView.bounds.size.height)
                [messagesTableView setContentOffset:CGPointMake(0, messagesTableView.contentSize.height - messagesTableView.bounds.size.height) animated:NO];
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    JSQMessage *chatMessage = [self.messages objectAtIndex:indexPath.section];
    //
    //    UILabel *messageLabel = [VATool getLabelWithTextString:chatMessage.text fontSize:18 textColor:[UIColor whiteColor] sapce:0 bold:YES];
    //    [messageLabel setPreferredMaxLayoutWidth:200.0];
    //
    //    float cellHeight = messageLabel.frame.size.height + 50;
    
    VAMessageFrame *messageFrame = allMessagesFrame[indexPath.section];
    float cellHeight = [messageFrame cellHeight];
    //    if (messageFrame.messageType != MessageTypeMe)
    //        cellHeight = cellHeight + 20;
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    
    return footerView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return UITableViewCellEditingStyleInsert;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        if ([@"" isEqualToString:textField.text])
            return NO;
        
        [self sendMessage:textField.text];
        
        return NO;
    }
    return YES;
}

- (void)sendMessage:(NSString *)message
{
    //    JSQMessage *chatMessage = [[JSQMessage alloc] init];
    //    chatMessage.senderDisplayName = @"user name";
    //    chatMessage.text = message;
    
    if (self.chatMessageType == ChatMessageTypeIT)
        [self.session sendMessageToIT:message];
    else
        [self.session sendMessageToAll:message];
    
    //    if (self.messages.count == 1) {
    //        CAGradientLayer *l = [CAGradientLayer layer];
    //        l.frame = messagesTableView.bounds;
    //        l.colors = [NSArray arrayWithObjects:
    //                    (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor],
    //                    (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] CGColor],
    //                    (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] CGColor],
    //                    (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor],
    //                    (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8] CGColor],
    //                    (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0] CGColor],nil];
    //
    //        l.startPoint = CGPointMake(0.0f, 0.0f);
    //        l.endPoint = CGPointMake(1, 1.0f);
    //
    //        //you can change the direction, obviously, this would be top to bottom fade
    //        messagesTableView.layer.mask = l;
    //    }
    
}

- (void)receiveMessage:(JSQMessage *)chatMessage
{
    //
    //
    //    [self.messages addObject:chatMessage];
    //
    //
    //
    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.allMessagesFrame.count];
    
    
    VAMessageFrame *messageFrame = [[VAMessageFrame alloc] init];
    NSString *senderDisplayNameToIT = [NSString stringWithFormat:@"%@ to IT", self.session.shortUserName];
    if ([chatMessage.senderDisplayName isEqualToString:self.session.shortUserName] || [chatMessage.senderDisplayName isEqualToString:senderDisplayNameToIT])
        messageFrame.messageType = MessageTypeMe;
    else
        messageFrame.messageType = MessageTypeOther;
    
    messageFrame.message = chatMessage;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString *time = [dateFormatter stringFromDate:chatMessage.date];
    
    messageFrame.showTime = ![previousTime isEqualToString:time];
    previousTime = time;
    
    [allMessagesFrame addObject:messageFrame];
    
    //    [messagesTableView reloadData];
    
    [self.messagesTableView insertSections:[NSIndexSet indexSetWithIndex:insertIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    
    [messagesTableView scrollToRowAtIndexPath:insertIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    if (messageFrame.messageType == MessageTypeMe)
        messageTextField.text = @"";
}
@end
