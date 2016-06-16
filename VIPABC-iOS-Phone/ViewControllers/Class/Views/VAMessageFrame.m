#import "VAMessageFrame.h"
#import "JSQMessage.h"

@implementation VAMessageFrame

- (void)setMessage:(JSQMessage *)message{
    
    _message = message;
    
    // 0、获取屏幕宽度
    CGFloat screenW = iPhone6 ? 350.0 : 320.0;
    // 1、计算时间的位置
    if (_showTime){
        
        CGFloat timeY = kMargin;
        CGSize timeSize = [[NSString stringWithFormat:@"%@", _message.date] sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kTimeFont,NSFontAttributeName, nil]];
        
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + kTimeMarginW, timeSize.height + kTimeMarginH);
    }
    // 2、计算头像位置
    CGFloat iconX = kMargin;
    // 2.1 如果是自己发得，头像在右边
    if (self.messageType == MessageTypeMe) {
        iconX = screenW - kMargin - kIconWH;
    }

    CGFloat iconY;
    if (self.messageType == MessageTypeMe)
        iconY = CGRectGetMaxY(_timeF) + kMargin;
    else
        iconY = CGRectGetMaxY(_timeF) + kMargin + kNameMargin;
    
    _iconF = CGRectMake(iconX, iconY, kIconWH, kIconWH);
    
    // 3、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF) + kMargin;
    CGFloat contentY = iconY;
//    CGSize contentSize = [_message.text sizeWithFont:kContentFont constrainedToSize:];
    
    NSDictionary *attribute = @{NSFontAttributeName:kContentFont};

    CGSize contentSize = [_message.text boundingRectWithSize:CGSizeMake(kContentW, CGFLOAT_MAX) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    if (self.messageType == MessageTypeMe) {
        contentX = iconX - kMargin - contentSize.width - kContentLeft - kContentRight;
    }
    
    _contentF = CGRectMake(contentX, contentY, contentSize.width + kContentLeft + kContentRight, contentSize.height + kContentTop + kContentBottom);

    // 4、计算高度
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_iconF))  + kMargin;
}

@end
