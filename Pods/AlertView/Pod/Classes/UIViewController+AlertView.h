//
//  UIViewController+AlertView.h
//  Pods
//
//  Created by TingYao Hsu on 2015/9/10.
//
//

#import <UIKit/UIKit.h>
#import "AlertView.h"

@interface UIViewController (AlertView)
+ (AlertView *)showAlertWithImage:(UIImage *)image title:(NSString *)title text:(NSString *)text;
@end
