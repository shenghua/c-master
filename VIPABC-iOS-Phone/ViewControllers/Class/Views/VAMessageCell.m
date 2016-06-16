#import "VAMessageCell.h"
#import "JSQMessage.h"
#import "VAMessageFrame.h"
#import "VATool.h"
#import "UIImageView+WebCache.h"
#import "VANetworkInterface.h"
#import "TMNNetworkLogicManager.h"
#import "JSONKit.h"

@interface VAMessageCell ()
{
    UIButton *_timeBtn;
//    UIImageView *_iconView;
    UILabel *_firstLetterLabel;
    UIButton *_contentBtn;
    UIImageView *_userImageView;
    UIImageView *_rightImageView;
    UIImageView *_leftImageView;
    UILabel *_nameLabel;
}

@end

@implementation VAMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // 1、创建时间按钮
        _timeBtn = [[UIButton alloc] init];
        [_timeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _timeBtn.titleLabel.font = kTimeFont;
        _timeBtn.enabled = NO;
//        [_timeBtn setBackgroundImage:[UIImage imageNamed:@"chat_timeline_bg.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:_timeBtn];
        
        // 2、创建头像
//        _iconView = [[UIImageView alloc] init];
//        [self.contentView addSubview:_iconView];
        
        _firstLetterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _firstLetterLabel.font = DEFAULT_FONT(14);
        _firstLetterLabel.textColor = [UIColor whiteColor];
        _firstLetterLabel.backgroundColor = RGBCOLOR(235, 112, 100, 1);
        _firstLetterLabel.layer.cornerRadius = 16;
        _firstLetterLabel.layer.masksToBounds = YES;
        _firstLetterLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_firstLetterLabel];
        
        _userImageView = [[UIImageView alloc] init];
        _userImageView.hidden = YES;
        [self.contentView addSubview:_userImageView];
        
        // 3、创建内容
        _contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        _contentBtn.titleLabel.font = kContentFont;
        _contentBtn.titleLabel.numberOfLines = 0;
        
        UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_contentBtn addGestureRecognizer:touch];
        
        [self.contentView addSubview:_contentBtn];
        
        _rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SessionRoomMessageChatRight"]];
        _rightImageView.hidden = YES;
        [self.contentView addSubview:_rightImageView];
        
        _leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SessionRoomMessageChatLeft"]];
        _leftImageView.hidden = YES;
        [self.contentView addSubview:_leftImageView];
    }
    return self;
}

- (void)setMessageFrame:(VAMessageFrame *)messageFrame{
    
    _messageFrame = messageFrame;
    JSQMessage *message = _messageFrame.message;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString *time = [dateFormatter stringFromDate:message.date];
    
    // 1、设置时间
    [_timeBtn setTitle:time forState:UIControlStateNormal];

    _timeBtn.frame = _messageFrame.timeF;
    
    // 2、设置头像
//    _iconView.image = [UIImage imageNamed:message.icon];
//    _iconView.frame = _messageFrame.iconF;
    
    if (message.senderDisplayName.length > 0)
        _firstLetterLabel.text = [[message.senderDisplayName substringToIndex:1] uppercaseString];
    else
        _firstLetterLabel.text = @"";
    _firstLetterLabel.frame = _messageFrame.iconF;
    _userImageView.frame = _messageFrame.iconF;
    
    // 3、设置内容
    [_contentBtn setTitle:message.text forState:UIControlStateNormal];
    _contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentLeft, kContentBottom, kContentRight);
    _contentBtn.frame = _messageFrame.contentF;
    
    if (_messageFrame.messageType == MessageTypeMe) {
        _contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentTop, kContentRight, kContentBottom, kContentLeft);
    }
    
    if (_messageFrame.messageType == MessageTypeMe) {
        [_contentBtn setBackgroundColor:RGBCOLOR(222, 124, 119, 1)];
        
        [_rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_contentBtn.right);
            make.centerY.equalTo(_userImageView);
        }];
        
        [VANetworkInterface fetchUserInfo:[TMNNetworkLogicManager sharedInstace].currentUser.clientSn successBlock:^(id responseObject) {
            NSString *jsonResult = [responseObject objectForKey:@"JsonResult"];
            NSData *resultData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonResultDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            [_userImageView sd_setImageWithURL:[NSURL URLWithString:[jsonResultDic objectForKey:@"HeadImgUrl"]] placeholderImage:[UIImage imageNamed:@"SessionRoomDefaultUserImage"]];
        } failedBlock:^(NSError *error, id responseObject) {
        }];
        
        _userImageView.image = [UIImage imageNamed:@"SessionRoomDefaultUserImage"];
        _userImageView.layer.cornerRadius = 16;
        _userImageView.layer.masksToBounds = YES;
        
        _firstLetterLabel.hidden = YES;
        _userImageView.hidden = NO;
        _rightImageView.hidden = NO;
        _leftImageView.hidden = YES;
        
        [_nameLabel removeFromSuperview];
    }else{
        [_contentBtn setBackgroundColor:RGBCOLOR(229, 229, 230, 1)];
        
        _firstLetterLabel.backgroundColor =self.isConsultant ? RGBCOLOR(74, 116, 178, 1) : RGBCOLOR(235, 112, 100, 1);
        
        [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_contentBtn.left);
            make.centerY.equalTo(_firstLetterLabel);
        }];
        
        _firstLetterLabel.hidden = NO;
        _userImageView.hidden = YES;
        _rightImageView.hidden = YES;
        _leftImageView.hidden = NO;
        
        [_nameLabel removeFromSuperview];
        _nameLabel = [VATool getLabelWithTextString:message.senderDisplayName fontSize:11 textColor:[UIColor whiteColor] sapce:0 bold:NO];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLabel];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_contentBtn);
            make.bottom.equalTo(_contentBtn.top).offset(-5);
        }];
    }
    _contentBtn.layer.cornerRadius = 5;
}

#pragma mark - UI Events
-(void)handleTap:(UIGestureRecognizer*) recognizer {
    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制"
                                                      action:@selector(copy:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
    [[UIMenuController sharedMenuController] setTargetRect:_contentBtn.frame inView:_contentBtn.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
}

-(void)copy:(id)sender {
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = _contentBtn.titleLabel.text;
}
@end
