//
//  ITHelperViewController.m
//  Pods
//
//  Created by TingYao Hsu on 2015/12/7.
//
//

#import "ITHelperViewController.h"

#import "LiveSession.h"
#import "UIFont+CustomFont.h"
#import "UIImage+RenderColor.h"

#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesViewController/UIColor+JSQMessages.h>
#import <JSQMessagesViewController/UIImage+JSQMessages.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface ITHelperViewController ()
@property (nonatomic, assign) BOOL scrollDragEnd;
@end

@implementation ITHelperViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // hide avatar image
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    // Customize input box
    self.inputToolbar.contentView.backgroundColor = UIColor.whiteColor;
    self.inputToolbar.contentView.rightBarButtonItemWidth = 54.f;
    self.inputToolbar.preferredDefaultHeight = 46.f;
    self.inputToolbar.maximumHeight = 80.f;
    
    // Update init state of input toolbar height
    // The library itself hardcoded the height in initializer
    // TODO: Should find the real constraints from IBOutlet or customized the layout
    [self.inputToolbar.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.constant == 44.f) {
            obj.constant = 46.f;
            *stop = YES;
        }
    }];
    
    [self.inputToolbar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isMemberOfClass:UIImageView.class]) {
            obj.alpha = .3f;
            *stop = YES;
        }
        
    }];
    UIButton *sendButton = self.inputToolbar.contentView.rightBarButtonItem;
    sendButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    
    [sendButton setTitle:@"傳送" forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_sand"] forState:UIControlStateNormal];
    [sendButton setTitleColor:UIColorFromRGB(0x00348DED) forState:UIControlStateNormal];
    
    [sendButton setTitle:@"傳送" forState:UIControlStateHighlighted];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"sessionroom_btn_sand"] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:UIColorFromRGB(0x00348DED) forState:UIControlStateHighlighted];
    
    [sendButton setTitle:@"傳送" forState:UIControlStateDisabled];
    [sendButton setBackgroundImage:[UIImage filledImageFrom:[UIImage imageNamed:@"sessionroom_btn_sand"] withColor:UIColor.lightGrayColor] forState:UIControlStateDisabled];
    [sendButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
    
    self.inputToolbar.contentView.textView.placeHolder = @"請輸入文字";
    self.inputToolbar.contentView.textView.font = [UIFont systemFontOfSize:14.f];
    self.inputToolbar.contentView.textView.layer.borderWidth = 0.f;
    self.inputToolbar.contentView.textView.layer.cornerRadius = 0.f;
    self.inputToolbar.contentView.leftContentPadding = 0.f;
    
    self.inputToolbar.contentView.leftBarButtonItem.hidden = YES;
    self.inputToolbar.contentView.leftBarButtonItemWidth = 0.f;
    
    self.collectionView.collectionViewLayout.messageBubbleLeftRightMargin = 30.f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.keyboardController endListeningForKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
    
    self.automaticallyScrollsToMostRecentMessage = NO;
    self.scrollDragEnd = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.automaticallyScrollsToMostRecentMessage && self.scrollDragEnd) {
        float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        BOOL isBottom = bottomEdge >= scrollView.contentSize.height;
        NSLog(@"scrollViewDidEndDragging isBottom: %@, shouldScroll: %@", @(isBottom), @(self.automaticallyScrollsToMostRecentMessage));
        if (isBottom) {
            self.automaticallyScrollsToMostRecentMessage = YES;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    self.scrollDragEnd = YES;
}

#pragma mark - private methoda
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - UI Action
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    
    [self.session sendMessageToIT:text];
    [self finishSendingMessage];
}

- (JSQMessagesBubbleImage *)messagesBubbleImageForIncoming:(BOOL)flippedForIncoming {
    
    UIImage *normalBubble = flippedForIncoming? [UIImage imageNamed:@"sessionroom_bg_chat_left"]: [UIImage imageNamed:@"sessionroom_bg_chat_right"];
    
    return [[JSQMessagesBubbleImage alloc] initWithMessageBubbleImage:normalBubble highlightedImage:normalBubble];
}

#pragma mark - JSQMessagesDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    JSQMessage *msg = self.messages[indexPath.item];
    if ([msg.senderId isEqualToString:self.senderId]) {
        cell.textView.textColor = UIColor.whiteColor;
    } else {
        cell.textView.textColor = UIColor.blackColor;
    }
    return cell;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return self.messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *msg = self.messages[indexPath.item];
    
    return [self messagesBubbleImageForIncoming:![msg.senderId isEqualToString:self.senderId]];
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *msg = self.messages[indexPath.item];
    
    NSMutableAttributedString *topLabelString = [[NSMutableAttributedString alloc] init];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"sessionroom_icon_clock"];
    attachment.bounds = CGRectMake(0, -3, attachment.image.size.width, attachment.image.size.height);
    NSAttributedString *clock = [NSAttributedString attributedStringWithAttachment:attachment];
    [topLabelString appendAttributedString:clock];
    [topLabelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    NSMutableAttributedString *sender = [[NSMutableAttributedString alloc] initWithString:msg.senderDisplayName attributes:@{NSFontAttributeName: [UIFont montserratFontOfSize:11.f]}];
    [topLabelString appendAttributedString:sender];
    [topLabelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:msg.date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
    [topLabelString appendAttributedString:dateString];
    return topLabelString;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}
@end
