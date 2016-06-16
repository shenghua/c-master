#import <UIKit/UIKit.h>
@class VAMessageFrame;

@interface VAMessageCell : UITableViewCell

@property (nonatomic, strong) VAMessageFrame *messageFrame;
@property (nonatomic, copy) NSString *userImageURL;
@property (nonatomic, assign) BOOL isConsultant;

@end
